{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.lanraragi;
in
{
  options.services = {
    lanraragi = {
      enable = lib.mkEnableOption "LANraragi";
      package = lib.mkPackageOption pkgs "lanraragi" { };

      openFirewall = lib.mkEnableOption "" // {
        description = "Open ports in the firewall for LANraragi's web interface.";
      };

      passwordFile = lib.mkOption {
        default = null;

        description = ''
          A file containing the password for LANraragi's admin interface.
        '';

        example = "/run/keys/lanraragi-password";
        type = lib.types.nullOr lib.types.path;
      };

      port = lib.mkOption {
        default = 3000;
        description = "Port for LANraragi's web interface.";
        type = lib.types.port;
      };

      redis = {
        passwordFile = lib.mkOption {
          default = null;

          description = ''
            A file containing the password for LANraragi's Redis server.
          '';

          example = "/run/keys/redis-lanraragi-password";
          type = lib.types.nullOr lib.types.path;
        };

        port = lib.mkOption {
          default = 6379;
          description = "Port for LANraragi's Redis server.";
          type = lib.types.port;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    services.redis.servers.lanraragi = {
      enable = true;
      port = cfg.redis.port;
      requirePassFile = cfg.redis.passwordFile;
    };

    systemd.services.lanraragi = {
      after = [
        "network.target"
        "redis-lanraragi.service"
      ];

      description = "LANraragi main service";

      environment = {
        "HOME" = "/var/lib/lanraragi";
        "LRR_LOG_DIRECTORY" = "/var/log/lanraragi";
        "LRR_NETWORK" = "http://*:${toString cfg.port}";
        "LRR_TEMP_DIRECTORY" = "/run/lanraragi";
      };

      preStart = ''
        cat > lrr.conf <<EOF
        {
          redis_address => "127.0.0.1:${toString cfg.redis.port}",
          redis_password => "${
            lib.optionalString (cfg.redis.passwordFile != null) "$(head -n1 ${cfg.redis.passwordFile})"
          }",
          redis_database => "0",
          redis_database_minion => "1",
          redis_database_config => "2",
          redis_database_search => "3",
        }
        EOF
      ''
      + lib.optionalString (cfg.passwordFile != null) ''
        ${lib.getExe pkgs.redis} -h 127.0.0.1 -p ${toString cfg.redis.port} ${
          lib.optionalString (cfg.redis.passwordFile != null) ''-a "$(head -n1 ${cfg.redis.passwordFile})"''
        }<<EOF
          SELECT 2
          HSET LRR_CONFIG password $(${cfg.package}/bin/helpers/lrr-make-password-hash $(head -n1 ${cfg.passwordFile}))
        EOF
      '';

      requires = [ "redis-lanraragi.service" ];

      serviceConfig = {
        DynamicUser = true;
        ExecStart = lib.getExe cfg.package;
        LogsDirectory = "lanraragi";
        Restart = "on-failure";
        RuntimeDirectory = "lanraragi";
        StateDirectory = "lanraragi";
        WorkingDirectory = "/var/lib/lanraragi";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ tomasajt ];
}
