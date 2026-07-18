{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.bitmagnet;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    optional
    ;
  inherit (lib.types)
    nullOr
    bool
    port
    str
    submodule
    ;
  inherit (lib.generators) toYAML;

  freeformType = (pkgs.formats.yaml { }).type;
in
{
  options.services.bitmagnet = {
    enable = mkEnableOption "Bitmagnet service";
    package = mkPackageOption pkgs "bitmagnet" { };

    group = mkOption {
      default = "bitmagnet";
      description = "Group of user running bitmagnet";
      type = str;
    };

    openFirewall = mkOption {
      default = false;
      description = "Open DHT ports in firewall";
      type = bool;
    };

    settings = mkOption {
      default = { };
      description = "Bitmagnet configuration (https://bitmagnet.io/setup/configuration.html).";

      type = submodule {
        inherit freeformType;

        options = {
          dht_server = mkOption {
            default = { };
            description = "DHT server settings";

            type = submodule {
              inherit freeformType;

              options = {
                port = mkOption {
                  default = 3334;
                  description = "DHT listen port";
                  type = port;
                };
              };
            };
          };

          http_server = mkOption {
            default = { };
            description = "HTTP server settings";

            type = submodule {
              inherit freeformType;

              options = {
                local_address = mkOption {
                  default = ":3333";
                  description = "HTTP server listen address";
                  type = str;
                };
              };
            };
          };

          postgres = mkOption {
            default = { };
            description = "PostgreSQL database configuration";

            type = submodule {
              inherit freeformType;

              options = {
                host = mkOption {
                  default = "";
                  description = "Address, hostname or Unix socket path of the database server";
                  type = str;
                };

                name = mkOption {
                  default = "bitmagnet";
                  description = "Database name to connect to";
                  type = str;
                };

                password = mkOption {
                  default = "";
                  description = "Password for database user";
                  type = str;
                };

                user = mkOption {
                  default = "";
                  description = "User to connect as";
                  type = str;
                };
              };
            };
          };

          tmdb = mkOption {
            default = { };
            description = "TMDB api settings";

            type = submodule {
              inherit freeformType;

              options = {
                api_key = mkOption {
                  default = null;
                  description = "TMDB api key, to avoid api limits. Leave null to use the default shared key.";
                  type = nullOr str;
                };
              };
            };
          };
        };
      };
    };

    useLocalPostgresDB = mkOption {
      default = true;
      description = "Use a local postgresql database, create user and database";
      type = bool;
    };

    user = mkOption {
      default = "bitmagnet";
      description = "User running bitmagnet";
      type = str;
    };
  };

  config = mkIf cfg.enable {
    environment.etc."xdg/bitmagnet/config.yml" = {
      group = cfg.group;
      mode = "0440";
      text = toYAML { } cfg.settings;
      user = cfg.user;
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.settings.dht_server.port ];
      allowedUDPPorts = [ cfg.settings.dht_server.port ];
    };

    services.postgresql = mkIf cfg.useLocalPostgresDB {
      enable = true;

      ensureDatabases = [
        cfg.settings.postgres.name
        (if (cfg.settings.postgres.user == "") then cfg.user else cfg.settings.postgres.user)
      ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = if (cfg.settings.postgres.user == "") then cfg.user else cfg.settings.postgres.user;
        }
      ];
    };

    systemd.services.bitmagnet = {
      enable = true;

      after = [
        "network.target"
      ]
      ++ optional cfg.useLocalPostgresDB "postgresql.target";

      requires = optional cfg.useLocalPostgresDB "postgresql.target";
      restartTriggers = [ config.environment.etc."xdg/bitmagnet/config.yml".source ];

      serviceConfig = {
        BindReadOnlyPaths = [ "/etc/xdg/bitmagnet/config.yml" ];
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/bitmagnet worker run --all";
        Group = cfg.group;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        # Sandboxing (sorted by occurrence in https://www.freedesktop.org/software/systemd/man/systemd.exec.html)
        ProtectSystem = "strict";
        RemoveIPC = true;
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "bitmagnet";
        Type = "simple";
        User = cfg.user;
        WorkingDirectory = "/var/lib/bitmagnet";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = mkIf (cfg.group == "bitmagnet") { bitmagnet = { }; };

    users.users = mkIf (cfg.user == "bitmagnet") {
      bitmagnet = {
        group = cfg.group;
        isSystemUser = true;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ gileri ];
}
