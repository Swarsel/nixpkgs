{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.cloudlog;
  dbFile =
    let
      password =
        if cfg.database.createLocally then
          "''"
        else
          "trim(file_get_contents('${cfg.database.passwordFile}'))";
    in
    pkgs.writeText "database.php" ''
      <?php
      defined('BASEPATH') OR exit('No direct script access allowed');
      $active_group = 'default';
      $query_builder = TRUE;
      $db['default'] = array(
        'dsn' => "",
        'hostname' => '${cfg.database.host}',
        'username' => '${cfg.database.user}',
        'password' => ${password},
        'database' => '${cfg.database.name}',
        'dbdriver' => 'mysqli',
        'dbprefix' => "",
        'pconnect' => TRUE,
        'db_debug' => (ENVIRONMENT !== 'production'),
        'cache_on' => FALSE,
        'cachedir' => "",
        'char_set' => 'utf8mb4',
        'dbcollat' => 'utf8mb4_general_ci',
        'swap_pre' => "",
        'encrypt' => FALSE,
        'compress' => FALSE,
        'stricton' => FALSE,
        'failover' => array(),
        'save_queries' => TRUE
      );
    '';
  configFile = pkgs.writeText "config.php" ''
    <?php
    include('${pkgs.cloudlog}/install/config/config.php');
    $config['datadir'] = "${cfg.dataDir}/";
    $config['base_url'] = "${cfg.baseUrl}";
    ${cfg.extraConfig}
  '';
  package = pkgs.stdenv.mkDerivation rec {
    installPhase = ''
      mkdir -p $out
      cp -r * $out/

      ln -s ${configFile} $out/application/config/config.php
      ln -s ${dbFile} $out/application/config/database.php

      # make a copy of the original assets/json to prime the datadir
      cp -a "$out/assets/json/" "$out/assets/json.original/"

      # link writable directories
      for directory in updates uploads backup logbook assets/qslcard images/eqsl_card_images assets/sstvimages assets/json; do
        rm -rf $out/$directory
        ln -s ${cfg.dataDir}/$directory $out/$directory
      done
    '';

    pname = "cloudlog";
    src = pkgs.cloudlog;
    version = src.version;
  };
in
{
  options.services.cloudlog = with types; {
    enable = mkEnableOption "Cloudlog";

    baseUrl = mkOption {
      default = "http://localhost";
      description = "Cloudlog base URL";
      type = str;
    };

    dataDir = mkOption {
      default = "/var/lib/cloudlog";
      description = "Cloudlog data directory.";
      type = str;
    };

    database = {
      createLocally = mkOption {
        default = true;
        description = "Create the database and database user locally.";
        type = types.bool;
      };

      host = mkOption {
        default = "localhost";
        description = "MySQL database host";
        type = str;
      };

      name = mkOption {
        default = "cloudlog";
        description = "MySQL database name.";
        type = str;
      };

      passwordFile = mkOption {
        default = null;
        description = "MySQL user password file.";
        type = nullOr str;
      };

      user = mkOption {
        default = "cloudlog";
        description = "MySQL user name.";
        type = str;
      };
    };

    extraConfig = mkOption {
      default = "";

      description = ''
        Any additional text to be appended to the config.php
        configuration file. This is a PHP script. For configuration
        settings, see <https://github.com/magicbug/Cloudlog/wiki/Cloudlog.php-Configuration-File>.
      '';

      example = ''
        $config['show_time'] = TRUE;
      '';

      type = str;
    };

    poolConfig = mkOption {
      default = {
        "pm" = "dynamic";
        "pm.max_children" = 32;
        "pm.max_requests" = 500;
        "pm.max_spare_servers" = 4;
        "pm.min_spare_servers" = 2;
        "pm.start_servers" = 2;
      };

      description = ''
        Options for Cloudlog's PHP-FPM pool.
      '';

      type = attrsOf (oneOf [
        str
        int
        bool
      ]);
    };

    update-clublog-scp = {
      enable = mkOption {
        default = true;

        description = ''
          Whether to periodically update the Clublog SCP database. If enabled,
          a systemd timer will run the update task as specified by the interval
          option.
        '';

        type = bool;
      };

      interval = mkOption {
        default = "monthly";

        description = ''
          Specification (in the format described by {manpage}`systemd.time(7)`) of the time
          at which the Clublog SCP update will occur.
        '';

        type = str;
      };
    };

    update-dok = {
      enable = mkOption {
        default = true;

        description = ''
          Whether to periodically update the DOK resource file. If enabled, a
          systemd timer will run the update task as specified by the interval option.
        '';

        type = bool;
      };

      interval = mkOption {
        default = "monthly";

        description = ''
          Specification (in the format described by {manpage}`systemd.time(7)`) of the
          time at which the DOK update will occur.
        '';

        type = str;
      };
    };

    update-lotw-users = {
      enable = mkOption {
        default = true;

        description = ''
          Whether to periodically update the list of LoTW users. If enabled, a
          systemd timer will run the update task as specified by the interval
          option.
        '';

        type = bool;
      };

      interval = mkOption {
        default = "weekly";

        description = ''
          Specification (in the format described by {manpage}`systemd.time(7)`) of the
          time at which the LoTW user update will occur.
        '';

        type = str;
      };
    };

    update-sota = {
      enable = mkOption {
        default = true;

        description = ''
          Whether to periodically update the SOTA database. If enabled, a
          systemd timer will run the update task as specified by the interval option.
        '';

        type = bool;
      };

      interval = mkOption {
        default = "monthly";

        description = ''
          Specification (in the format described by {manpage}`systemd.time(7)`) of the time
          at which the SOTA update will occur.
        '';

        type = str;
      };
    };

    update-wwff = {
      enable = mkOption {
        default = true;

        description = ''
          Whether to periodically update the WWFF database. If enabled, a
          systemd timer will run the update task as specified by the interval
          option.
        '';

        type = bool;
      };

      interval = mkOption {
        default = "monthly";

        description = ''
          Specification (in the format described by {manpage}`systemd.time(7)`) of the time
          at which the WWFF update will occur.
        '';

        type = str;
      };
    };

    upload-clublog = {
      enable = mkOption {
        default = true;

        description = ''
          Whether to periodically upload logs to Clublog. If enabled, a systemd
          timer will run the log upload task as specified by the interval option.
        '';

        type = bool;
      };

      interval = mkOption {
        default = "daily";

        description = ''
          Specification (in the format described by {manpage}`systemd.time(7)`) of the time
          at which the Clublog upload will occur.
        '';

        type = str;
      };
    };

    upload-lotw = {
      enable = mkOption {
        default = true;

        description = ''
          Whether to periodically upload logs to LoTW. If enabled, a systemd
          timer will run the log upload task as specified by the interval
           option.
        '';

        type = bool;
      };

      interval = mkOption {
        default = "daily";

        description = ''
          Specification (in the format described by {manpage}`systemd.time(7)`) of the
          time at which the LoTW upload will occur.
        '';

        type = str;
      };
    };

    upload-qrz = {
      enable = mkOption {
        default = true;

        description = ''
          Whether to periodically upload logs to QRZ. If enabled, a systemd
          timer will run the update task as specified by the interval option.
        '';

        type = bool;
      };

      interval = mkOption {
        default = "daily";

        description = ''
          Specification (in the format described by {manpage}`systemd.time(7)`) of the
          time at which the QRZ upload will occur.
        '';

        type = str;
      };
    };

    user = mkOption {
      default = "cloudlog";
      description = "User account under which Cloudlog runs.";
      type = str;
    };

    virtualHost = mkOption {
      default = "localhost";

      description = ''
        Name of the nginx virtualhost to use and setup. If null, do not setup
         any virtualhost.
      '';

      type = nullOr str;
    };
  };

  config = mkIf cfg.enable {

    assertions = [
      {
        assertion = cfg.database.createLocally -> cfg.database.passwordFile == null;
        message = "services.cloudlog.database.passwordFile cannot be specified if services.cloudlog.database.createLocally is set to true.";
      }
    ];

    services.mysql = mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [ cfg.database.name ];

      ensureUsers = [
        {
          ensurePermissions = {
            "${cfg.database.name}.*" = "ALL PRIVILEGES";
          };

          name = cfg.database.user;
        }
      ];
    };

    services.nginx = mkIf (cfg.virtualHost != null) {
      enable = true;

      virtualHosts = {
        "${cfg.virtualHost}" = {
          locations."/".tryFiles = "$uri /index.php$is_args$args";

          locations."~ ^/index.php(/|$)".extraConfig = ''
            include ${config.services.nginx.package}/conf/fastcgi_params;
            include ${pkgs.nginx}/conf/fastcgi.conf;
            fastcgi_split_path_info ^(.+\.php)(.+)$;
            fastcgi_pass unix:${config.services.phpfpm.pools.cloudlog.socket};
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
          '';

          root = "${package}";
        };
      };
    };

    services.phpfpm = {
      pools.cloudlog = {
        inherit (cfg) user;
        group = config.services.nginx.group;

        settings = {
          "listen.group" = config.services.nginx.group;
          "listen.owner" = config.services.nginx.user;
        }
        // cfg.poolConfig;
      };
    };

    systemd = {
      services = {
        cloudlog-setup-database = mkIf cfg.database.createLocally {
          after = [ "mysql.service" ];
          description = "Set up cloudlog database";

          script =
            let
              mysql = "${config.services.mysql.package}/bin/mysql";
            in
            ''
              if [ ! -f ${cfg.dataDir}/.dbexists ]; then
                ${mysql} ${cfg.database.name} < ${pkgs.cloudlog}/install/assets/install.sql
                touch ${cfg.dataDir}/.dbexists
              fi
            '';

          serviceConfig = {
            RemainAfterExit = true;
            Type = "oneshot";
          };

          wantedBy = [ "phpfpm-cloudlog.service" ];
        };

        cloudlog-update-clublog-scp = {
          enable = cfg.update-clublog-scp.enable;
          description = "Update Clublog SCP Database File";
          script = "${pkgs.curl}/bin/curl -s ${cfg.baseUrl}/update/update_clublog_scp";
        };

        cloudlog-update-dok = {
          enable = cfg.update-dok.enable;
          description = "Update DOK File for autocomplete";
          script = "${pkgs.curl}/bin/curl -s ${cfg.baseUrl}/update/update_dok";
        };

        cloudlog-update-lotw-users = {
          enable = cfg.update-lotw-users.enable;
          description = "Update LOTW Users Database";
          script = "${pkgs.curl}/bin/curl -s ${cfg.baseUrl}/lotw/load_users";
        };

        cloudlog-update-sota = {
          enable = cfg.update-sota.enable;
          description = "Update SOTA File for autocomplete";
          script = "${pkgs.curl}/bin/curl -s ${cfg.baseUrl}/update/update_sota";
        };

        cloudlog-update-wwff = {
          enable = cfg.update-wwff.enable;
          description = "Update WWFF File for autocomplete";
          script = "${pkgs.curl}/bin/curl -s ${cfg.baseUrl}/update/update_wwff";
        };

        cloudlog-upload-lotw = {
          enable = cfg.upload-lotw.enable;
          description = "Upload QSOs to LoTW if certs have been provided";
          script = "${pkgs.curl}/bin/curl -s ${cfg.baseUrl}/lotw/lotw_upload";
        };

        cloudlog-upload-qrz = {
          enable = cfg.upload-qrz.enable;
          description = "Upload QSOs to QRZ Logbook";
          script = "${pkgs.curl}/bin/curl -s ${cfg.baseUrl}/qrz/upload";
        };
      };

      timers = {
        cloudlog-update-clublog-scp = {
          enable = cfg.update-clublog-scp.enable;
          after = [ "phpfpm-cloudlog.service" ];
          partOf = [ "cloudlog-update-clublog-scp.service" ];

          timerConfig = {
            OnCalendar = cfg.update-clublog-scp.interval;
            Persistent = true;
          };

          wantedBy = [ "timers.target" ];
        };

        cloudlog-update-dok = {
          enable = cfg.update-dok.enable;
          after = [ "phpfpm-cloudlog.service" ];
          partOf = [ "cloudlog-update-dok.service" ];

          timerConfig = {
            OnCalendar = cfg.update-dok.interval;
            Persistent = true;
          };

          wantedBy = [ "timers.target" ];
        };

        cloudlog-update-lotw-users = {
          enable = cfg.update-lotw-users.enable;
          after = [ "phpfpm-cloudlog.service" ];
          partOf = [ "cloudlog-update-lotw-users.service" ];

          timerConfig = {
            OnCalendar = cfg.update-lotw-users.interval;
            Persistent = true;
          };

          wantedBy = [ "timers.target" ];
        };

        cloudlog-update-sota = {
          enable = cfg.update-sota.enable;
          after = [ "phpfpm-cloudlog.service" ];
          partOf = [ "cloudlog-update-sota.service" ];

          timerConfig = {
            OnCalendar = cfg.update-sota.interval;
            Persistent = true;
          };

          wantedBy = [ "timers.target" ];
        };

        cloudlog-update-wwff = {
          enable = cfg.update-wwff.enable;
          after = [ "phpfpm-cloudlog.service" ];
          partOf = [ "cloudlog-update-wwff.service" ];

          timerConfig = {
            OnCalendar = cfg.update-wwff.interval;
            Persistent = true;
          };

          wantedBy = [ "timers.target" ];
        };

        cloudlog-upload-clublog = {
          enable = cfg.upload-clublog.enable;
          after = [ "phpfpm-cloudlog.service" ];
          partOf = [ "cloudlog-upload-clublog.service" ];

          timerConfig = {
            OnCalendar = cfg.upload-clublog.interval;
            Persistent = true;
          };

          wantedBy = [ "timers.target" ];
        };

        cloudlog-upload-lotw = {
          enable = cfg.upload-lotw.enable;
          after = [ "phpfpm-cloudlog.service" ];
          partOf = [ "cloudlog-upload-lotw.service" ];

          timerConfig = {
            OnCalendar = cfg.upload-lotw.interval;
            Persistent = true;
          };

          wantedBy = [ "timers.target" ];
        };

        cloudlog-upload-qrz = {
          enable = cfg.upload-qrz.enable;
          after = [ "phpfpm-cloudlog.service" ];
          partOf = [ "cloudlog-upload-qrz.service" ];

          timerConfig = {
            OnCalendar = cfg.upload-qrz.interval;
            Persistent = true;
          };

          wantedBy = [ "timers.target" ];
        };
      };

      tmpfiles.rules =
        let
          group = config.services.nginx.group;
        in
        [
          "d ${cfg.dataDir}                         0750 ${cfg.user} ${group} - -"
          "d ${cfg.dataDir}/updates                 0750 ${cfg.user} ${group} - -"
          "d ${cfg.dataDir}/uploads                 0750 ${cfg.user} ${group} - -"
          "d ${cfg.dataDir}/backup                  0750 ${cfg.user} ${group} - -"
          "d ${cfg.dataDir}/logbook                 0750 ${cfg.user} ${group} - -"
          "d ${cfg.dataDir}/assets                  0750 ${cfg.user} ${group} - -"
          "d ${cfg.dataDir}/assets/json             0750 ${cfg.user} ${group} - -"
          "d ${cfg.dataDir}/assets/qslcard          0750 ${cfg.user} ${group} - -"
          "d ${cfg.dataDir}/assets/sstvimages       0750 ${cfg.user} ${group} - -"
          "d ${cfg.dataDir}/images                  0750 ${cfg.user} ${group} - -"
          "d ${cfg.dataDir}/images/eqsl_card_images 0750 ${cfg.user} ${group} - -"
          "C ${cfg.dataDir}/assets/json/dok.txt                              0640 ${cfg.user} ${group} - ${package}/assets/json.original/dok.txt"
          "C ${cfg.dataDir}/assets/json/pota.txt                             0640 ${cfg.user} ${group} - ${package}/assets/json.original/pota.txt"
          "C ${cfg.dataDir}/assets/json/satellite_data.json                  0640 ${cfg.user} ${group} - ${package}/assets/json.original/satellite_data.json"
          "C ${cfg.dataDir}/assets/json/sota.txt                             0640 ${cfg.user} ${group} - ${package}/assets/json.original/sota.txt"
          "C ${cfg.dataDir}/assets/json/US_counties.csv                      0640 ${cfg.user} ${group} - ${package}/assets/json.original/US_counties.csv"
          "C ${cfg.dataDir}/assets/json/us_national_parksontheair.csv        0640 ${cfg.user} ${group} - ${package}/assets/json.original/us_national_parksontheair.csv"
          "C ${cfg.dataDir}/assets/json/WABSquares.geojson                   0640 ${cfg.user} ${group} - ${package}/assets/json.original/WABSquares.geojson"
          "C ${cfg.dataDir}/assets/json/wwff.txt                             0640 ${cfg.user} ${group} - ${package}/assets/json.original/wwff.txt"
          "C+ ${cfg.dataDir}/assets/json/datatables_languages                0750 ${cfg.user} ${group} - ${package}/assets/json.original/datatables_languages"
        ];
    };

    users.users."${cfg.user}" = {
      group = config.services.nginx.group;
      isSystemUser = true;
    };
  };

  meta.maintainers = pkgs.cloudlog.meta.maintainers;
}
