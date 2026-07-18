{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.certmgr;

  specs = lib.mapAttrsToList (n: v: rec {
    name = n + ".json";
    path = if lib.isAttrs v then pkgs.writeText name (builtins.toJSON v) else v;
  }) cfg.specs;

  allSpecs = pkgs.linkFarm "certmgr.d" specs;

  certmgrYaml = pkgs.writeText "certmgr.yaml" (
    builtins.toJSON {
      inherit (cfg) metricsPort metricsAddress;
      before = cfg.validMin;
      default_remote = cfg.defaultRemote;
      dir = allSpecs;
      interval = cfg.renewInterval;
      svcmgr = cfg.svcManager;
    }
  );

  specPaths = map dirOf (
    lib.concatMap (
      spec:
      if lib.isAttrs spec then
        lib.collect lib.isString (lib.filterAttrsRecursive (n: v: lib.isAttrs v || n == "path") spec)
      else
        [ spec ]
    ) (lib.attrValues cfg.specs)
  );

  preStart = ''
    ${lib.concatStringsSep " \\\n" ([ "mkdir -p" ] ++ map lib.escapeShellArg specPaths)}
    ${cfg.package}/bin/certmgr -f ${certmgrYaml} check
  '';
in
{
  options.services.certmgr = {
    enable = lib.mkEnableOption "certmgr";
    package = lib.mkPackageOption pkgs "certmgr" { };

    defaultRemote = lib.mkOption {
      default = "127.0.0.1:8888";
      description = "The default CA host:port to use.";
      type = lib.types.str;
    };

    metricsAddress = lib.mkOption {
      default = "127.0.0.1";
      description = "The address for the Prometheus HTTP endpoint.";
      type = lib.types.str;
    };

    metricsPort = lib.mkOption {
      default = 9488;
      description = "The port for the Prometheus HTTP endpoint.";
      type = lib.types.ints.u16;
    };

    renewInterval = lib.mkOption {
      default = "30m";
      description = "How often to check certificate expirations and how often to update the cert_next_expires metric.";
      type = lib.types.str;
    };

    specs = lib.mkOption {
      default = { };

      description = ''
        Certificate specs as described by:
        <https://github.com/cloudflare/certmgr#certificate-specs>
        These will be added to the Nix store, so they will be world readable.
      '';

      example = lib.literalExpression ''
        {
          exampleCert =
          let
            domain = "example.com";
            secret = name: "/var/lib/secrets/''${name}.pem";
          in {
            service = "nginx";
            action = "reload";
            authority = {
              file.path = secret "ca";
            };
            certificate = {
              path = secret domain;
            };
            private_key = {
              owner = "root";
              group = "root";
              mode = "0600";
              path = secret "''${domain}-key";
            };
            request = {
              CN = domain;
              hosts = [ "mail.''${domain}" "www.''${domain}" ];
              key = {
                algo = "rsa";
                size = 2048;
              };
              names = {
                O = "Example Organization";
                C = "USA";
              };
            };
          };
          otherCert = "/var/certmgr/specs/other-cert.json";
        }
      '';

      type =
        with lib.types;
        attrsOf (
          either path (submodule {
            options = {
              action = lib.mkOption {
                default = "nop";
                description = "The action to take after fetching.";

                type = addCheck str (
                  x:
                  cfg.svcManager == "command"
                  || lib.elem x [
                    "restart"
                    "reload"
                    "nop"
                  ]
                );
              };

              # These ought all to be specified according to certmgr spec def.
              authority = lib.mkOption {
                description = "certmgr spec authority object.";
                type = attrs;
              };

              certificate = lib.mkOption {
                description = "certmgr spec certificate object.";
                type = nullOr attrs;
              };

              private_key = lib.mkOption {
                description = "certmgr spec private_key object.";
                type = nullOr attrs;
              };

              request = lib.mkOption {
                description = "certmgr spec request object.";
                type = nullOr attrs;
              };

              service = lib.mkOption {
                default = null;
                description = "The service on which to perform \\<action\\> after fetching.";
                type = nullOr str;
              };
            };
          })
        );
    };

    svcManager = lib.mkOption {
      default = "systemd";

      description = ''
        This specifies the service manager to use for restarting or reloading services.
        See: <https://github.com/cloudflare/certmgr#certmgryaml>.
        For how to use the "command" service manager in particular,
        see: <https://github.com/cloudflare/certmgr#command-svcmgr-and-how-to-use-it>.
      '';

      type = lib.types.enum [
        "circus"
        "command"
        "dummy"
        "openrc"
        "systemd"
        "sysv"
      ];
    };

    validMin = lib.mkOption {
      default = "72h";
      description = "The interval before a certificate expires to start attempting to renew it.";
      type = lib.types.str;
    };

  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.specs != { };
        message = "Certmgr specs cannot be empty.";
      }
      {
        assertion =
          !lib.any (lib.hasAttrByPath [
            "authority"
            "auth_key"
          ]) (lib.attrValues cfg.specs);

        message = ''
          Inline services.certmgr.specs are added to the Nix store rendering them world readable.
          Specify paths as specs, if you want to use include auth_key - or use the auth_key_file option."
        '';
      }
    ];

    systemd.services.certmgr = {
      inherit preStart;
      after = [ "network-online.target" ];
      description = "certmgr";
      path = lib.mkIf (cfg.svcManager == "command") [ pkgs.bash ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/certmgr -f ${certmgrYaml}";
        Restart = "always";
        RestartSec = "10s";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };
}
