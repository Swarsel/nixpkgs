{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    mkEnableOption
    mkPackageOption
    mapAttrs
    optional
    boolToString
    isBool
    mkIf
    getExe
    types
    ;

  cfg = config.services.snips-sh;
in
{
  options.services.snips-sh = {
    enable = mkEnableOption "snips.sh";

    package = mkPackageOption pkgs "snips-sh" {
      example = "pkgs.snips-sh.override {withTensorflow = true;}";
    };

    environmentFile = mkOption {
      default = null;

      description = ''
        Additional environment file as defined in {manpage}`systemd.exec(5)`.

        Sensitive secrets such as {env}`SNIPS_SSH_HOSTKEYPATH` and {env}`SNIPS_METRICS_STATSD`
        may be passed to the service while avoiding potentially making them world-readable in the nix store or
        to convert an existing non-nix installation with minimum hassle.

        Note that this file needs to be available on the host on which
        `snips-sh` is running.
      '';

      example = "/etc/snips-sh.env";
      type = with types; nullOr path;
    };

    settings = mkOption {
      default = { };

      description = ''
        The configuration of snips-sh is done through environment variables,
        therefore you must use upper snake case (e.g. {env}`SNIPS_HTTP_INTERNAL`).

        Based on the attributes passed to this config option an environment file will be generated
        that is passed to snips-sh's systemd service.

        The available configuration options can be found in
        [self-hosting guide](https://github.com/robherley/snips.sh/blob/main/docs/self-hosting.md#configuration) to
        find about the environment variables you can use.
      '';

      example = {
        SNIPS_HTTP_INTERNAL = "http://0.0.0.0:8080";
        SNIPS_SSH_INTERNAL = "ssh://0.0.0.0:2222";
      };

      type = types.submodule {
        options = {
          SNIPS_HTTP_INTERNAL = mkOption {
            description = "The internal HTTP address of the service";
            type = types.str;
          };

          SNIPS_SSH_INTERNAL = mkOption {
            description = "The internal SSH address of the service";
            type = types.str;
          };
        };

        freeformType = types.attrsOf (
          types.nullOr (
            types.oneOf [
              types.str
              types.int
              types.bool
            ]
          )
        );
      };
    };

    stateDir = mkOption {
      default = "/var/lib/snips-sh";
      description = "The state directory of the service.";
      type = types.path;
    };
  };

  config = mkIf cfg.enable {
    systemd = {
      services.snips-sh = {
        after = [ "network-online.target" ];
        environment = mapAttrs (_: v: if isBool v then boolToString v else toString v) cfg.settings;

        serviceConfig = {
          AmbientCapabilities = "CAP_NET_BIND_SERVICE";
          CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
          # hardening
          DynamicUser = true;
          EnvironmentFile = optional (cfg.environmentFile != null) cfg.environmentFile;
          ExecStart = getExe cfg.package;
          LimitNOFILE = "1048576";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectSystem = "strict";
          RemoveIPC = true;
          Restart = "always";

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_UNIX"
          ];

          RestrictNamespaces = true;
          RestrictSUIDSGID = true;
          RuntimeDirectory = "snips-sh";
          StateDirectory = "snips-sh";
          StateDirectoryMode = "0700";
          SystemCallFilter = "@system-service";
          WorkingDirectory = cfg.stateDir;
        };

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
      };

      tmpfiles.settings."10-snips-sh" = {
        "${cfg.stateDir}/data".D = {
          mode = "0755";
        };
      };
    };
  };

  meta.maintainers = with lib.maintainers; [
    isabelroses
    NotAShelf
  ];
}
