{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.knot-resolver;
  # pkgs.writers.yaml_1_1.generate with additional kresctl validate
  configFile = pkgs.callPackage (
    {
      remarshal_0_17,
      runCommandLocal,
      stdenv,
    }:
    runCommandLocal "knot-resolver.yaml"
      {
        nativeBuildInputs = [ remarshal_0_17 ];
        passAsFile = [ "value" ];
        value = builtins.toJSON cfg.settings;
      }
      ''
        json2yaml "$valuePath" "$out"
        ${
          # We skip validation if the build platform cannot execute # the binary targeting the host platform.
          lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
            ${cfg.managerPackage}/bin/kresctl validate "$out"
          ''
        }
      ''
  ) { };
in
{
  ###### interface
  options.services.knot-resolver = {
    enable = lib.mkOption {
      default = false;

      description = ''
        Whether to enable knot-resolver (version 6) domain name server.
        DNSSEC validation is turned on by default.
        If you want to use knot-resolver 5, please use services.kresd.
      '';

      type = lib.types.bool;
    };

    managerPackage = lib.mkPackageOption pkgs "knot-resolver-manager_6" {
      example = "pkgs.knot-resolver-manager_6.override { extraFeatures = true; }";
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Nix-based (RFC 42) configuration for Knot Resolver.
        For configuration reference (described as YAML) see
        <https://www.knot-resolver.cz/documentation/latest/config-overview.html>
      '';

      type = lib.types.submodule {
        options = {
          network.listen = lib.mkOption {
            default = [
              {
                freebind = false;
                interface = [ "127.0.0.1" ];
                kind = "dns";
              }
            ]
            ++ lib.optionals config.networking.enableIPv6 [
              {
                freebind = false;
                interface = [ "::1" ];
                kind = "dns";
              }
            ];

            defaultText = lib.literalExpression ''
              [
                {
                  interface = [ "127.0.0.1" ];
                  kind = "dns";
                  freebind = false;
                }
              ]
              ++ lib.optionals config.networking.enableIPv6 [
                {
                  interface = [ "::1" ];
                  kind = "dns";
                  freebind = false;
                }
               ];
            '';

            description = "List of interfaces to listen to and its configuration.";

            type = lib.types.listOf (
              lib.types.submodule {
                freeformType = (pkgs.formats.yaml { }).type;
              }
            );
          };

          workers = lib.mkOption {
            default = 1;

            description = ''
              The number of running kresd (Knot Resolver daemon) workers. If set to 'auto', it is equal to number of CPUs available.
            '';

            type = lib.types.oneOf [
              (lib.types.enum [ "auto" ])
              lib.types.ints.unsigned
            ];
          };
        };

        freeformType = (pkgs.formats.yaml { }).type;
      };
    };
  };

  ###### implementation
  config = lib.mkIf cfg.enable {
    environment = {
      etc."knot-resolver/config.yaml".source = configFile;

      systemPackages = [
        # We just avoid including the other binaries, e.g. supervisorctl.
        (pkgs.runCommandLocal "knot-resolver-cmds" { } ''
          mkdir -p "$out/bin"
          ln -s '${cfg.managerPackage}/bin/kresctl' "$out/bin/"
        '')
      ];
    };

    networking.resolvconf.useLocalResolver = lib.mkDefault true;
    systemd.packages = [ cfg.managerPackage.kresd ]; # the unit gets patched a bit just below

    systemd.services."knot-resolver" = {
      reloadTriggers = [
        configFile
      ];

      serviceConfig = {
        CacheDirectory = "knot-resolver";
        CacheDirectoryMode = "0770";
        ExecReload = "${cfg.managerPackage}/bin/kresctl reload";
        ExecStart = "${cfg.managerPackage}/bin/knot-resolver";
        RuntimeDirectory = "knot-resolver";
        RuntimeDirectoryMode = "0770";
        StateDirectory = "knot-resolver";
        StateDirectoryMode = "0770";
      };

      stopIfChanged = false;
      wantedBy = [ "multi-user.target" ];
    };

    users.groups.knot-resolver = { };

    users.users.knot-resolver = {
      description = "Knot-resolver daemon user";
      group = "knot-resolver";
      isSystemUser = true;
    };
  };

  meta.maintainers = [
    lib.maintainers.vcunat # upstream developer
    lib.maintainers.leona
    lib.maintainers.osnyx
  ];
}
