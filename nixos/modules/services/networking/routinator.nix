{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  inherit (lib)
    filterAttrsRecursive
    getExe
    maintainers
    mkEnableOption
    mkIf
    mkPackageOption
    mkOption
    types
    ;
  inherit (utils) escapeSystemdExecArgs;
  cfg = config.services.routinator;
  settingsFormat = pkgs.formats.toml { };
in
{
  options.services.routinator = {
    enable = mkEnableOption "Routinator 3000";
    package = mkPackageOption pkgs "routinator" { };

    extraArgs = mkOption {
      default = [ ];

      description = ''
        Extra arguments passed to routinator, see <https://routinator.docs.nlnetlabs.nl/en/stable/manual-page.html#options> for options.";
      '';

      example = [ "--no-rir-tals" ];
      type = types.listOf types.str;
    };

    extraServerArgs = mkOption {
      default = [ ];

      description = ''
        Extra arguments passed to the server subcommand, see <https://routinator.docs.nlnetlabs.nl/en/stable/manual-page.html#subcmd-server> for options.";
      '';

      example = [ "--rtr-client-metrics" ];
      type = types.listOf types.str;
    };

    settings = mkOption {
      default = { };

      description = ''
        Configuration for Routinator 3000, see <https://routinator.docs.nlnetlabs.nl/en/stable/manual-page.html#configuration-file> for options.
      '';

      type = types.submodule {
        options = {
          expire = mkOption {
            default = 7200;

            description = ''
              An integer value specifying the number of seconds an RTR client is requested to use a data set if it cannot get an update before throwing it away and continuing with no data at all.
            '';

            type = types.nullOr types.int;
          };

          http-listen = mkOption {
            default = null;

            description = ''
              An array of string values each providing an address and port on which the HTTP server should listen. Address and port should be separated by a colon. IPv6 address should be enclosed in square brackets.
            '';

            type = types.nullOr (types.listOf types.str);
          };

          log = mkOption {
            default = "default";

            description = ''
              A string specifying where to send log messages to.
              See, <https://routinator.docs.nlnetlabs.nl/en/stable/manual-page.html#term-log>
            '';

            type = types.nullOr (
              types.enum [
                "default"
                "stderr"
                "syslog"
                "file"
              ]
            );
          };

          log-file = mkOption {
            default = null;

            description = ''
              A string value containing the path to a file to which log messages will be appended if the log configuration value is set to file. In this case, the value is mandatory.
            '';

            type = types.nullOr types.path;
          };

          log-level = mkOption {
            default = "warn";

            description = ''
              A string value specifying the maximum log level for which log messages should be emitted.
              See, <https://routinator.docs.nlnetlabs.nl/en/stable/manual-page.html#logging>
            '';

            type = types.nullOr (
              types.enum [
                "error"
                "warn"
                "info"
                "debug"
              ]
            );
          };

          refresh = mkOption {
            default = 600;

            description = ''
              An integer value specifying the number of seconds Routinator should wait between consecutive validation runs in server mode. The next validation run will happen earlier, if objects expire earlier.
            '';

            type = types.nullOr types.int;
          };

          repository-dir = mkOption {
            default = "/var/lib/routinator/rpki-cache";

            description = ''
              The path where the collected RPKI data is stored.
            '';

            type = types.path;
          };

          retry = mkOption {
            default = 600;

            description = ''
              An integer value specifying the number of seconds an RTR client is requested to wait after it failed to receive a data set.
            '';

            type = types.nullOr types.int;
          };

          rtr-listen = mkOption {
            default = null;

            description = ''
              An array of string values each providing an address and port on which the RTR server should listen in TCP mode. Address and port should be separated by a colon. IPv6 address should be enclosed in square brackets.
            '';

            type = types.nullOr (types.listOf types.str);
          };
        };

        freeformType = settingsFormat.type;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.routinator = {
      after = [ "network.target" ];
      description = "Routinator 3000 is free, open-source RPKI Relying Party software made by NLnet Labs.";
      path = with pkgs; [ rsync ];

      serviceConfig = {
        CapabilityBoundingSet = [ "" ];
        DynamicUser = true;

        ExecStart = escapeSystemdExecArgs (
          [
            (getExe cfg.package)
            "--config=${
              settingsFormat.generate "routinator.conf" (filterAttrsRecursive (n: v: v != null) cfg.settings)
            }"
          ]
          ++ cfg.extraArgs
          ++ [
            "server"
          ]
          ++ cfg.extraServerArgs
        );

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        StateDirectory = "routinator";
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";
        SystemCallFilter = "@system-service";
        Type = "exec";
        UMask = "0027";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with maintainers; [ xgwq ];
}
