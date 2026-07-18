{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.grocy;
in
{
  options.services.grocy = {
    enable = mkEnableOption "grocy";
    package = mkPackageOption pkgs "grocy" { };

    dataDir = mkOption {
      default = "/var/lib/grocy";

      description = ''
        Home directory of the `grocy` user which contains
        the application's state.
      '';

      type = types.str;
    };

    extraConfig = mkOption {
      default = "";

      description = ''
        These lines go at the end of config.php verbatim.
      '';

      example = ''
        Setting('FEATURE_FLAG_RECIPES', false);
        Setting('FEATURE_FLAG_STOCK_PRODUCT_FREEZING', false);
      '';

      type = types.lines;
    };

    hostName = mkOption {
      description = ''
        FQDN for the grocy instance.
      '';

      type = types.str;
    };

    nginx.enableSSL = mkOption {
      default = true;

      description = ''
        Whether or not to enable SSL (with ACME and let's encrypt)
        for the grocy vhost.
      '';

      type = types.bool;
    };

    phpfpm.settings = mkOption {
      default = {
        "catch_workers_output" = true;
        "listen.owner" = config.services.nginx.user;
        "php_admin_flag[log_errors]" = true;
        "php_admin_value[error_log]" = "stderr";
        "pm" = "dynamic";
        "pm.max_children" = "32";
        "pm.max_requests" = "500";
        "pm.max_spare_servers" = "4";
        "pm.min_spare_servers" = "2";
        "pm.start_servers" = "2";
      };

      defaultText = lib.literalExpression ''
        {
          "pm" = "dynamic";
          "php_admin_value[error_log]" = "stderr";
          "php_admin_flag[log_errors]" = true;
          "listen.owner" = config.services.nginx.user;
          "catch_workers_output" = true;
          "pm.max_children" = "32";
          "pm.start_servers" = "2";
          "pm.min_spare_servers" = "2";
          "pm.max_spare_servers" = "4";
          "pm.max_requests" = "500";
        }
      '';

      description = ''
        Options for grocy's PHPFPM pool.
      '';

      type =
        with types;
        attrsOf (oneOf [
          int
          str
          bool
        ]);
    };

    settings = {
      calendar = {
        firstDayOfWeek = mkOption {
          default = null;

          description = ''
            Which day of the week (0=Sunday, 1=Monday etc.) should be the
            first day.
          '';

          type = types.nullOr (types.enum (range 0 6));
        };

        showWeekNumber = mkOption {
          default = true;

          description = ''
            Show the number of the weeks in the calendar views.
          '';

          type = types.bool;
        };
      };

      culture = mkOption {
        default = "en";

        description = ''
          Display language of the frontend.
        '';

        type = types.enum [
          "bg_BG"
          "ca"
          "cs"
          "da"
          "de"
          "el_GR"
          "en"
          "en_GB"
          "es"
          "et_EE"
          "fi"
          "fr"
          "he_IL"
          "hu"
          "it"
          "ja"
          "ko_KR"
          "lt"
          "nl"
          "no"
          "pl"
          "pt_BR"
          "pt_PT"
          "ro_RO"
          "ru"
          "sk_SK"
          "sl"
          "sv_SE"
          "ta"
          "tr"
          "uk"
          "zh_CN"
          "zh_TW"
        ];
      };

      currency = mkOption {
        default = "USD";

        description = ''
          ISO 4217 code for the currency to display.
        '';

        example = "EUR";
        type = types.str;
      };

      entryPage = mkOption {
        default = "stock";

        description = ''
          Specify an custom homepage if desired.
        '';

        # https://github.com/grocy/grocy/blob/v4.6.0/config-dist.php#L75-L78
        type = types.enum [
          "stock"
          "shoppinglist"
          "recipes"
          "chores"
          "tasks"
          "batteries"
          "equipment"
          "calendar"
          "mealplan"
        ];
      };
    };
  };

  config = mkIf cfg.enable {
    environment.etc."grocy/config.php".text = ''
      <?php
      Setting('CULTURE', '${cfg.settings.culture}');
      Setting('CURRENCY', '${cfg.settings.currency}');
      Setting('CALENDAR_FIRST_DAY_OF_WEEK', '${toString cfg.settings.calendar.firstDayOfWeek}');
      Setting('CALENDAR_SHOW_WEEK_OF_YEAR', ${boolToString cfg.settings.calendar.showWeekNumber});
      Setting('ENTRY_PAGE', '${cfg.settings.entryPage}');
      ${cfg.extraConfig}
    '';

    services.nginx = {
      enable = true;

      virtualHosts."${cfg.hostName}" = mkMerge [
        {
          extraConfig = ''
            try_files $uri /index.php;
          '';

          locations."/".extraConfig = ''
            rewrite ^ /index.php;
          '';

          locations."~ \\.(js|css|ttf|woff2?|png|jpe?g|svg)$".extraConfig = ''
            add_header Cache-Control "public, max-age=15778463";
            add_header X-Content-Type-Options nosniff;
            add_header X-Robots-Tag none;
            add_header X-Download-Options noopen;
            add_header X-Permitted-Cross-Domain-Policies none;
            add_header Referrer-Policy no-referrer;
            access_log off;
          '';

          locations."~ \\.php$".extraConfig = ''
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:${config.services.phpfpm.pools.grocy.socket};
            include ${config.services.nginx.package}/conf/fastcgi.conf;
            include ${config.services.nginx.package}/conf/fastcgi_params;
          '';

          root = "${cfg.package}/public";
        }
        (mkIf cfg.nginx.enableSSL {
          enableACME = true;
          forceSSL = true;
        })
      ];
    };

    services.phpfpm.pools.grocy = {
      inherit (cfg.phpfpm) settings;
      inherit (cfg.package.passthru) phpPackage;
      group = "nginx";

      phpEnv = {
        GROCY_CACHE_DIR = "${cfg.dataDir}/viewcache";
        GROCY_CONFIG_FILE = "/etc/grocy/config.php";
        GROCY_DB_FILE = "${cfg.dataDir}/grocy.db";
        GROCY_PLUGIN_DIR = "${cfg.dataDir}/plugins";
        GROCY_STORAGE_DIR = "${cfg.dataDir}/storage";
      };

      user = "grocy";
    };

    # After an update of grocy, the viewcache needs to be deleted. Otherwise grocy will not work
    # https://github.com/grocy/grocy#how-to-update
    systemd.services.grocy-setup = {
      before = [ "phpfpm-grocy.service" ];

      script = ''
        rm -rf ${cfg.dataDir}/viewcache/*
      '';

      unitConfig.RequiresMountsFor = [ cfg.dataDir ];
      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = map (dirName: "d '${cfg.dataDir}/${dirName}' - grocy nginx - -") [
      "viewcache"
      "plugins"
      "settingoverrides"
      "storage"
    ];

    users.users.grocy = {
      createHome = true;
      group = "nginx";
      home = cfg.dataDir;
      isSystemUser = true;
    };
  };

  meta = {
    doc = ./grocy.md;
    maintainers = with maintainers; [ diogotcorreia ];
  };
}
