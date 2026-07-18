{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    maintainers
    types
    escapeShellArg
    escapeShellArgs
    mkEnableOption
    mkOption
    mkRemovedOptionModule
    mkIf
    mkPackageOption
    concatMapStrings
    concatStringsSep
    ;

  cfg = config.services.mtr-exporter;

  jobsConfig = pkgs.writeText "mtr-exporter.conf" (
    concatMapStrings (job: ''
      ${job.name} -- ${job.schedule} -- ${concatStringsSep " " job.flags} ${job.address}
    '') cfg.jobs
  );
in
{
  imports = [
    (mkRemovedOptionModule [
      "services"
      "mtr-exporter"
      "target"
    ] "Use services.mtr-exporter.jobs instead.")
    (mkRemovedOptionModule [
      "services"
      "mtr-exporter"
      "mtrFlags"
    ] "Use services.mtr-exporter.jobs.<job>.flags instead.")
  ];

  options = {
    services = {
      mtr-exporter = {
        enable = mkEnableOption "a Prometheus exporter for MTR";
        package = mkPackageOption pkgs "mtr-exporter" { };

        address = mkOption {
          default = "127.0.0.1";
          description = "Listen address for MTR exporter.";
          type = types.str;
        };

        extraFlags = mkOption {
          default = [ ];

          description = ''
            Extra command line options to pass to MTR exporter.
          '';

          example = [ "-flag.deprecatedMetrics" ];
          type = types.listOf types.str;
        };

        jobs = mkOption {
          description = "List of MTR jobs. Will be added to /etc/mtr-exporter.conf";

          type = types.nonEmptyListOf (
            types.submodule {
              options = {
                address = mkOption {
                  description = "Target address for MTR client.";
                  example = "host.example.org:1234";
                  type = types.str;
                };

                flags = mkOption {
                  default = [ ];
                  description = "Additional flags to pass to MTR.";
                  example = [ "-G1" ];
                  type = with types; listOf str;
                };

                name = mkOption {
                  description = "Name of ICMP pinging job.";
                  type = types.str;
                };

                schedule = mkOption {
                  default = "@every 60s";
                  description = "Schedule of MTR checks. Also accepts Cron format.";
                  example = "@hourly";
                  type = types.str;
                };
              };
            }
          );
        };

        mtrPackage = mkPackageOption pkgs "mtr" { };

        port = mkOption {
          default = 8080;
          description = "Listen port for MTR exporter.";
          type = types.port;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    environment.etc."mtr-exporter.conf" = {
      source = jobsConfig;
    };

    systemd.services.mtr-exporter = {
      after = [ "network.target" ];
      requires = [ "network.target" ];

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = [ "" ];
        DynamicUser = true;

        ExecStart = ''
          ${cfg.package}/bin/mtr-exporter \
            -mtr '${cfg.mtrPackage}/bin/mtr' \
            -bind ${escapeShellArg "${cfg.address}:${toString cfg.port}"} \
            -jobs '${jobsConfig}' \
            ${escapeShellArgs cfg.extraFlags}
        '';

        LockPersonality = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        Restart = "on-failure";
        RestrictNamespaces = true;
        RestrictRealtime = true;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with maintainers; [ jakubgs ];
}
