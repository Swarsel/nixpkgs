{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.selfoss;

  poolName = "selfoss_pool";

  dataDir = "/var/lib/selfoss";

  selfoss-config =
    let
      db_type = cfg.database.type;
      default_port = if (db_type == "mysql") then 3306 else 5342;
    in
    pkgs.writeText "selfoss-config.ini" ''
      [globals]
      ${lib.optionalString (db_type != "sqlite") ''
        db_type=${db_type}
        db_host=${cfg.database.host}
        db_database=${cfg.database.name}
        db_username=${cfg.database.user}
        db_password=${cfg.database.password}
        db_port=${toString (if (cfg.database.port != null) then cfg.database.port else default_port)}
      ''}
      ${cfg.extraConfig}
    '';
in
{
  options = {
    services.selfoss = {
      enable = mkEnableOption "selfoss";

      database = {
        host = mkOption {
          default = "localhost";

          description = ''
            Host of the database (has no effect if type is "sqlite").
          '';

          type = types.str;
        };

        name = mkOption {
          default = "tt_rss";

          description = ''
            Name of the existing database (has no effect if type is "sqlite").
          '';

          type = types.str;
        };

        password = mkOption {
          default = null;

          description = ''
            The database user's password (has no effect if type is "sqlite").
          '';

          type = types.nullOr types.str;
        };

        port = mkOption {
          default = null;

          description = ''
            The database's port. If not set, the default ports will be
            provided (5432 and 3306 for pgsql and mysql respectively)
            (has no effect if type is "sqlite").
          '';

          type = types.nullOr types.port;
        };

        type = mkOption {
          default = "sqlite";

          description = ''
            Database to store feeds. Supported are sqlite, pgsql and mysql.
          '';

          type = types.enum [
            "pgsql"
            "mysql"
            "sqlite"
          ];
        };

        user = mkOption {
          default = "tt_rss";

          description = ''
            The database user. The user must exist and has access to
            the specified database (has no effect if type is "sqlite").
          '';

          type = types.str;
        };
      };

      extraConfig = mkOption {
        default = "";

        description = ''
          Extra configuration added to config.ini
        '';

        type = types.lines;
      };

      pool = mkOption {
        default = "${poolName}";

        description = ''
          Name of existing phpfpm pool that is used to run web-application.
          If not specified a pool will be created automatically with
          default values.
        '';

        type = types.str;
      };

      user = mkOption {
        default = config.services.nginx.user;
        defaultText = lib.literalExpression "config.services.nginx.user";

        description = ''
          User account under which both the service and the web-application run.
        '';

        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    services.phpfpm.pools = mkIf (cfg.pool == "${poolName}") {
      ${poolName} = {
        settings = mapAttrs (name: mkDefault) {
          "catch_workers_output" = 1;
          "listen.group" = config.services.nginx.group;
          "listen.mode" = "0600";
          "listen.owner" = config.services.nginx.user;
          "pm" = "dynamic";
          "pm.max_children" = 75;
          "pm.max_requests" = 500;
          "pm.max_spare_servers" = 20;
          "pm.min_spare_servers" = 5;
          "pm.start_servers" = 10;
        };

        user = config.services.nginx.user;
      };
    };

    systemd.services.selfoss-config = {
      script = ''
        mkdir -m 755 -p ${dataDir}
        cd ${dataDir}

        # Delete all but the "data" folder
        ls | grep -v data | while read line; do rm -rf $line; done || true

        # Create the files
        cp -r \
          "${pkgs.selfoss}/.htaccess" \
          "${pkgs.selfoss}/.nginx.conf" \
          "${pkgs.selfoss}/"* \
          "${dataDir}"
        ln -sf "${selfoss-config}" "${dataDir}/config.ini"
        chown -R "${cfg.user}" "${dataDir}"
        chmod -R 755 "${dataDir}"
      '';

      serviceConfig.Type = "oneshot";
      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.selfoss-update = {
      after = [ "selfoss-config.service" ];

      serviceConfig = {
        ExecStart = "${pkgs.php83}/bin/php ${dataDir}/cliupdate.php";
        User = "${cfg.user}";
      };

      startAt = "hourly";
      wantedBy = [ "multi-user.target" ];

    };

  };
}
