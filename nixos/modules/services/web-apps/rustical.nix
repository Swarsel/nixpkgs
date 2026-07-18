{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    mkPackageOption
    types
    ;

  cfg = config.services.rustical;

  format = pkgs.formats.toml { };
  configFile = format.generate "rustical.toml" cfg.settings;
in

{
  options.services.rustical = {
    enable = mkEnableOption "RustiCali CalDAV/CardDAV server";
    package = mkPackageOption pkgs "rustical" { };

    environmentFiles = mkOption {
      default = [ ];

      description = ''
        Environment files to load into the runtime environment.

        Check the documentation for how to construct [environment variables].

        :::{.tip}
        Environment variables can substitute any config value and are useful for
        hiding secrets.
        :::

        [environment variables]: https://lennart-k.github.io/rustical/installation/configuration/#environment-variables
      '';

      example = [ "/run/keys/rustical.env" ];
      type = with types; listOf path;
    };

    settings = mkOption {
      description = ''
        Your {file}`/etc/rustical/config.toml` as a Nix attribute set.

        Possible options can be found in the [Config struct]. A default
        configuration can be viewed by running `rustical gen-config`.

        [Config struct]: https://lennart-k.github.io/rustical/_crate/rustical/config/struct.Config.html
      '';

      type = types.submodule {
        options = {
          data_store.sqlite = {
            db_url = mkOption {
              default = "/var/lib/rustical/db.sqlite3";

              description = ''
                Path where the sqlite database is stored.
              '';

              type = types.path;
            };
          };

          dav_push.enabled = mkOption {
            default = true;

            description = ''
              Whether to enable [WebDav Push] support.

              This allows the server to notify clients about changed data.

              [WebDav Push]: https://github.com/bitfireAT/webdav-push/
            '';

            type = types.bool;
          };

          frontend = {
            enabled = mkEnableOption "the HTTP frontend" // {
              default = true;
            };
          };

          http = {
            bind = mkOption {
              default = "unix:/run/rustical/sock";

              description = ''
                Address and port or UNIX socket path to bind the HTTP service to.

                :::{.note}
                Rustical expects to be hosted behind a reverse proxy that
                provides HTTPS. Without HTTPS, the web frontend and some clients
                (e.g. Apple Calendar) may not work.
                :::
              '';

              example = "[::]:4000";
              type = types.str;
            };
          };

          nextcloud_login.enabled = mkOption {
            default = true;

            description = ''
              Whether to emulate the Nextcloud login flow.

              This is supported in [DAVx5] and enables automatic app token generation.

              [DAVx5]: https://www.davx5.com/
            '';

            type = types.bool;
          };
        };

        freeformType = format.type;
      };
    };
  };

  config = mkIf cfg.enable {
    # install the config at a path where the cli will find it
    environment.etc."rustical/config.toml".source = configFile;
    # provide the rustical cli
    environment.systemPackages = [ cfg.package ];

    systemd.services.rustical = {
      description = "RustiCal CalDav/CardDav server";
      documentation = [ "https://lennart-k.github.io/rustical/" ];
      restartTriggers = [ configFile ];

      serviceConfig = {
        CapabilityBoundingSet = "";
        DevicePolicy = "closed";
        DynamicUser = true;
        EnvironmentFile = cfg.environmentFiles;
        ExecStart = lib.getExe cfg.package;
        LockPersonality = true;
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
        ProtectSystem = "strict";
        RemoveIPC = true;
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RuntimeDirectory = "rustical";
        RuntimeDirectoryMode = "0750";
        StateDirectory = "rustical";
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";

        SystemCallFilter = [
          "@system-service"
          "~@privileged @resources"
        ];

        UMask = "0007";
      };

      wantedBy = [ "multi-user.target" ];
    };

    warnings = lib.optionals (cfg.settings.http ? host || cfg.settings.http ? port) [
      ''
        Rustical 0.13 deprecations

        The following options are now deprecated and will be removed in a
        future release:
        - `services.rustical.settings.http.host`
        - `services.rustical.settings.http.port`

        Migrate to `services.rustical.settings.http.bind` instead.
      ''
    ];
  };
}
