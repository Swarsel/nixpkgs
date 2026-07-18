{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.anuko-time-tracker;
  configFile =
    let
      smtpPassword =
        if cfg.settings.email.smtpPasswordFile == null then
          "''"
        else
          "trim(file_get_contents('${cfg.settings.email.smtpPasswordFile}'))";

    in
    pkgs.writeText "config.php" ''
      <?php
      // Set include path for PEAR and its modules, which we include in the distribution.
      // Updated for the correct location in the nix store.
      set_include_path('${cfg.package}/WEB-INF/lib/pear' . PATH_SEPARATOR . get_include_path());
      define('DSN', 'mysqli://${cfg.database.user}@${cfg.database.host}/${cfg.database.name}?charset=utf8mb4');
      define('MULTIORG_MODE', ${lib.boolToString cfg.settings.multiorgMode});
      define('EMAIL_REQUIRED', ${lib.boolToString cfg.settings.emailRequired});
      define('WEEKEND_START_DAY', ${toString cfg.settings.weekendStartDay});
      define('FORUM_LINK', '${cfg.settings.forumLink}');
      define('HELP_LINK', '${cfg.settings.helpLink}');
      define('SENDER', '${cfg.settings.email.sender}');
      define('MAIL_MODE', '${cfg.settings.email.mode}');
      define('MAIL_SMTP_HOST', '${toString cfg.settings.email.smtpHost}');
      define('MAIL_SMTP_PORT', '${toString cfg.settings.email.smtpPort}');
      define('MAIL_SMTP_USER', '${cfg.settings.email.smtpUser}');
      define('MAIL_SMTP_PASSWORD', ${smtpPassword});
      define('MAIL_SMTP_AUTH', ${lib.boolToString cfg.settings.email.smtpAuth});
      define('MAIL_SMTP_DEBUG', ${lib.boolToString cfg.settings.email.smtpDebug});
      define('DEFAULT_CSS', 'default.css');
      define('RTL_CSS', 'rtl.css'); // For right to left languages.
      define('LANG_DEFAULT', '${cfg.settings.defaultLanguage}');
      define('CURRENCY_DEFAULT', '${cfg.settings.defaultCurrency}');
      define('EXPORT_DECIMAL_DURATION', ${lib.boolToString cfg.settings.exportDecimalDuration});
      define('REPORT_FOOTER', ${lib.boolToString cfg.settings.reportFooter});
      define('AUTH_MODULE', 'db');
    '';
  package = pkgs.stdenv.mkDerivation rec {
    inherit (src) version;

    installPhase = ''
      mkdir -p $out
      cp -r * $out/

      # Link config file
      ln -s ${configFile} $out/WEB-INF/config.php

      # Link writable templates_c directory
      rm -rf $out/WEB-INF/templates_c
      ln -s ${cfg.dataDir}/templates_c $out/WEB-INF/templates_c

      # Remove unsafe dbinstall.php
      rm -f $out/dbinstall.php
    '';

    pname = "anuko-time-tracker";
    src = cfg.package;
  };
in
{
  options.services.anuko-time-tracker = {
    enable = lib.mkEnableOption "Anuko Time Tracker";
    package = lib.mkPackageOption pkgs "anuko-time-tracker" { };

    dataDir = lib.mkOption {
      default = "/var/lib/anuko-time-tracker";
      description = "Default data folder for Anuko Time Tracker.";
      example = "/mnt/anuko-time-tracker";
      type = lib.types.str;
    };

    database = {
      createLocally = lib.mkOption {
        default = true;
        description = "Create the database and database user locally.";
        type = lib.types.bool;
      };

      host = lib.mkOption {
        default = "localhost";
        description = "Database host.";
        type = lib.types.str;
      };

      name = lib.mkOption {
        default = "anuko_time_tracker";
        description = "Database name.";
        type = lib.types.str;
      };

      passwordFile = lib.mkOption {
        default = null;
        description = "Database user password file.";
        type = lib.types.nullOr lib.types.str;
      };

      user = lib.mkOption {
        default = "anuko_time_tracker";
        description = "Database username.";
        type = lib.types.str;
      };
    };

    hostname = lib.mkOption {
      default =
        if config.networking.domain != null then config.networking.fqdn else config.networking.hostName;

      defaultText = lib.literalExpression "config.networking.fqdn";

      description = ''
        The hostname to serve Anuko Time Tracker on.
      '';

      example = "anuko.example.com";
      type = lib.types.str;
    };

    nginx = lib.mkOption {
      default = { };

      description = ''
        With this option, you can customize the Nginx virtualHost settings.
      '';

      example = lib.literalExpression ''
        {
          serverAliases = [
            "anuko.''${config.networking.domain}"
          ];

          # To enable encryption and let let's encrypt take care of certificate
          forceSSL = true;
          enableACME = true;
        }
      '';

      type = lib.types.submodule (
        lib.recursiveUpdate (import ../web-servers/nginx/vhost-options.nix { inherit config lib; }) { }
      );
    };

    poolConfig = lib.mkOption {
      default = {
        "pm" = "dynamic";
        "pm.max_children" = 32;
        "pm.max_requests" = 500;
        "pm.max_spare_servers" = 4;
        "pm.min_spare_servers" = 2;
        "pm.start_servers" = 2;
      };

      description = ''
        Options for Anuko Time Tracker's PHP-FPM pool.
      '';

      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.str
          lib.types.int
          lib.types.bool
        ]
      );
    };

    settings = {
      defaultCurrency = lib.mkOption {
        default = "$";

        description = ''
          Defines a default currency symbol for new groups.
          Use €, £, a more specific dollar like US$, CAD, etc.
        '';

        example = "€";
        type = lib.types.str;
      };

      defaultLanguage = lib.mkOption {
        default = "";

        description = ''
          Defines Anuko Time Tracker default language. It is used on Time Tracker login page.
          After login, a language set for user group is used.
          Empty string means the language is defined by user browser.
        '';

        example = "nl";
        type = lib.types.str;
      };

      email = {
        mode = lib.mkOption {
          default = "smtp";
          description = "Mail sending mode. Can be 'mail' or 'smtp'.";
          type = lib.types.str;
        };

        sender = lib.mkOption {
          default = "Anuko Time Tracker <bounces@example.com>";
          description = "Default sender for mail.";
          type = lib.types.str;
        };

        smtpAuth = lib.mkOption {
          default = false;
          description = "MTA requires authentication.";
          type = lib.types.bool;
        };

        smtpDebug = lib.mkOption {
          default = false;
          description = "Debug mail sending.";
          type = lib.types.bool;
        };

        smtpHost = lib.mkOption {
          default = "localhost";
          description = "MTA hostname.";
          type = lib.types.str;
        };

        smtpPasswordFile = lib.mkOption {
          default = null;

          description = ''
            Path to file containing the MTA authentication password.
          '';

          example = "/var/lib/anuko-time-tracker/secrets/smtp-password";
          type = lib.types.nullOr lib.types.path;
        };

        smtpPort = lib.mkOption {
          default = 25;
          description = "MTA port.";
          type = lib.types.port;
        };

        smtpUser = lib.mkOption {
          default = "";
          description = "MTA authentication username.";
          type = lib.types.str;
        };
      };

      emailRequired = lib.mkOption {
        default = false;
        description = "Defines whether an email is required for new registrations.";
        type = lib.types.bool;
      };

      exportDecimalDuration = lib.mkOption {
        default = true;

        description = ''
          Defines whether time duration values are decimal in CSV and XML data
          exports (1.25 vs 1:15).
        '';

        type = lib.types.bool;
      };

      forumLink = lib.mkOption {
        default = "https://www.anuko.com/forum/viewforum.php?f=4";
        description = "Forum link from the main menu.";
        type = lib.types.str;
      };

      helpLink = lib.mkOption {
        default = "https://www.anuko.com/time-tracker/user-guide/index.htm";
        description = "Help link from the main menu.";
        type = lib.types.str;
      };

      multiorgMode = lib.mkOption {
        default = true;

        description = ''
          Defines whether users see the Register option in the menu of Time Tracker that allows them
          to self-register and create new organizations (top groups).
        '';

        type = lib.types.bool;
      };

      reportFooter = lib.mkOption {
        default = true;
        description = "Defines whether to use a footer on reports.";
        type = lib.types.bool;
      };

      weekendStartDay = lib.mkOption {
        default = 6;

        description = ''
          This option defines which days are highlighted with weekend color.
          6 means Saturday. For Saudi Arabia, etc. set it to 4 for Thursday and Friday to be
          weekend days.
        '';

        type = lib.types.int;
      };
    };

    user = lib.mkOption {
      default = "anuko_time_tracker";
      description = "User under which Anuko Time Tracker runs.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = cfg.database.createLocally -> cfg.database.passwordFile == null;

        message = ''
          <option>services.anuko-time-tracker.database.passwordFile</option> cannot be specified if
          <option>services.anuko-time-tracker.database.createLocally</option> is set to true.
        '';
      }
      {
        assertion = cfg.settings.email.smtpAuth -> (cfg.settings.email.smtpPasswordFile != null);

        message = ''
          <option>services.anuko-time-tracker.settings.email.smtpPasswordFile</option> needs to be set if
          <option>services.anuko-time-tracker.settings.email.smtpAuth</option> is enabled.
        '';
      }
    ];

    services.mysql = lib.mkIf cfg.database.createLocally {
      enable = lib.mkDefault true;
      package = lib.mkDefault pkgs.mariadb;
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

    services.nginx = {
      enable = lib.mkDefault true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;

      virtualHosts."${cfg.hostname}" = lib.mkMerge [
        cfg.nginx
        {
          locations = {
            "/".index = "index.php";

            "~ [^/]\\.php(/|$)" = {
              extraConfig = ''
                fastcgi_split_path_info ^(.+?\.php)(/.*)$;
                fastcgi_pass unix:${config.services.phpfpm.pools.anuko-time-tracker.socket};
              '';
            };
          };

          root = lib.mkForce "${package}";
        }
      ];
    };

    services.phpfpm = {
      pools.anuko-time-tracker = {
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
        anuko-time-tracker-setup-database = lib.mkIf cfg.database.createLocally {
          after = [ "mysql.service" ];
          description = "Set up Anuko Time Tracker database";

          script =
            let
              mysql = "${config.services.mysql.package}/bin/mysql";
            in
            ''
              if [ ! -f ${cfg.dataDir}/.dbexists ]; then
                # Load database schema provided with package
                ${mysql} ${cfg.database.name} < ${cfg.package}/mysql.sql

                touch ${cfg.dataDir}/.dbexists
              fi
            '';

          serviceConfig = {
            RemainAfterExit = true;
            Type = "oneshot";
          };

          wantedBy = [ "phpfpm-anuko-time-tracker.service" ];
        };
      };

      tmpfiles.rules = [
        "d ${cfg.dataDir} 0750 ${cfg.user} ${config.services.nginx.group} -"
        "d ${cfg.dataDir}/templates_c 0750 ${cfg.user} ${config.services.nginx.group} -"
      ];
    };

    users.users."${cfg.user}" = {
      group = config.services.nginx.group;
      isSystemUser = true;
    };
  };

  meta.maintainers = [ ];
}
