#v Non-module dependencies (`importApply`)
{ pkgs }:

# Service module
{
  lib,
  config,
  options,
  ...
}:
let
  cfg = config.autoconnect;
  tomlFmt = pkgs.formats.toml { };
in
{
  _class = "service";

  config =
    let
      configFile = tomlFmt.generate "autoconnect.toml" cfg.settings;
    in
    {
      process.argv = [
        "${config.package}/bin/autoconnect"
        "-c"
        (toString configFile)
      ];
    }
    // lib.optionalAttrs (options ? systemd) {
      systemd.service = {
        after = [ "network.target" ];

        serviceConfig = {
          DynamicUser = true;
          LockPersonality = true;
          #hardening
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
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
          ProtectSystem = "full";
          RemoveIPC = true;
          Restart = "on-failure";
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RuntimeDirectoryMode = 755;
          StateDirectoryMode = 0700;
          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "~@clock"
            "~@cpu-emulation"
            "~@debug"
            "~@module"
            "~@mount"
            "~@obsolete"
            "~@raw-io"
            "~@reboot"
            "~@swap"
          ];

          UMask = 077;
        };

        wantedBy = [ "multi-user.target" ];
        wants = [ "network.target" ];
      };
    };

  options = {
    autoconnect.settings = lib.mkOption {
      default = { };
      description = "";

      type = lib.types.submodule {
        freeformType = tomlFmt.type;

        options = {
          db_dsn = lib.mkOption {
            default = "";
            description = "Endpoint of the database server.";
            example = lib.literalExpression "redis+socket://\${config.services.redis.servers.autopush-rs.port}";
            type = lib.types.str;
          };
        };
      };
    };

    package = lib.mkPackageOption pkgs "autopush-rs.out" { };
  };
}
