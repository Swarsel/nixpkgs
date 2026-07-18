{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.icingaweb2;
  fpm = config.services.phpfpm.pools.${poolName};
  poolName = "icingaweb2";

  defaultConfig = {
    global = {
      module_path = "${pkgs.icingaweb2}/modules";
    };
  };
in
{
  options.services.icingaweb2 = with types; {
    enable = mkEnableOption "the icingaweb2 web interface";

    authentications = mkOption {
      default = null;

      description = ''
        authentication.ini contents.
        Will automatically be converted to a .ini file.

        If the value is null, no authentication.ini is created and you can
        modify it manually (e.g. via the web interface).
      '';

      example = {
        icingaweb = {
          backend = "db";
          resource = "icingaweb_db";
        };
      };

      type = nullOr attrs;
    };

    generalConfig = mkOption {
      default = null;

      description = ''
        config.ini contents.
        Will automatically be converted to a .ini file.
        If you don't set global.module_path, the module will take care of it.

        If the value is null, no config.ini is created and you can
        modify it manually (e.g. via the web interface).
        Note that you need to update module_path manually.
      '';

      example = {
        general = {
          config_resource = "icingaweb_db";
          showStacktraces = 1;
        };

        logging = {
          level = "CRITICAL";
          log = "syslog";
        };
      };

      type = nullOr attrs;
    };

    groupBackends = mkOption {
      default = null;

      description = ''
        groups.ini contents.
        Will automatically be converted to a .ini file.

        If the value is null, no groups.ini is created and you can
        modify it manually (e.g. via the web interface).
      '';

      example = {
        icingaweb = {
          backend = "db";
          resource = "icingaweb_db";
        };
      };

      type = nullOr attrs;
    };

    libraryPaths = mkOption {
      default = { };

      description = ''
        Libraries to add to the Icingaweb2 library path.
        The name of the attribute is the name of the library, the value
        is the package to add.
      '';

      type = attrsOf package;
    };

    modulePackages = mkOption {
      default = { };

      description = ''
        Name-package attrset of Icingaweb 2 modules packages to enable.

        If you enable modules manually (e.g. via the web ui), they will not be touched.
      '';

      example = literalExpression ''
        {
          "snow" = icingaweb2Modules.theme-snow;
        }
      '';

      type = attrsOf package;
    };

    modules = {
      doc.enable = mkEnableOption "the icingaweb2 doc module";
      migrate.enable = mkEnableOption "the icingaweb2 migrate module";
      setup.enable = mkEnableOption "the icingaweb2 setup module";
      test.enable = mkEnableOption "the icingaweb2 test module";
      translation.enable = mkEnableOption "the icingaweb2 translation module";
    };

    pool = mkOption {
      default = poolName;

      description = ''
        Name of existing PHP-FPM pool that is used to run Icingaweb2.
        If not specified, a pool will automatically created with default values.
      '';

      type = str;
    };

    resources = mkOption {
      default = null;

      description = ''
        resources.ini contents.
        Will automatically be converted to a .ini file.

        If the value is null, no resources.ini is created and you can
        modify it manually (e.g. via the web interface).
        Note that if you set passwords here, they will go into the nix store.
      '';

      example = {
        icingaweb_db = {
          db = "mysql";
          dbname = "icingaweb2";
          host = "localhost";
          password = "icingaweb2";
          type = "db";
          username = "icingaweb2";
        };
      };

      type = nullOr attrs;
    };

    roles = mkOption {
      default = null;

      description = ''
        roles.ini contents.
        Will automatically be converted to a .ini file.

        If the value is null, no roles.ini is created and you can
        modify it manually (e.g. via the web interface).
      '';

      example = {
        Administrators = {
          permissions = "*";
          users = "admin";
        };
      };

      type = nullOr attrs;
    };

    timezone = mkOption {
      default = "UTC";
      description = "PHP-compliant timezone specification";
      example = "Europe/Berlin";
      type = str;
    };

    virtualHost = mkOption {
      default = "icingaweb2";

      description = ''
        Name of the nginx virtualhost to use and setup. If null, no virtualhost is set up.
      '';

      type = nullOr str;
    };
  };

  config = mkIf cfg.enable {
    # /etc/icingaweb2
    environment.etc =
      let
        doModule =
          name:
          optionalAttrs (cfg.modules.${name}.enable) {
            "icingaweb2/enabledModules/${name}".source = "${pkgs.icingaweb2}/modules/${name}";
          };
      in
      { }
      # Module packages
      // (mapAttrs' (
        k: v: nameValuePair "icingaweb2/enabledModules/${k}" { source = v; }
      ) cfg.modulePackages)
      # Built-in modules
      // doModule "doc"
      // doModule "migrate"
      // doModule "setup"
      // doModule "test"
      // doModule "translation"
      # Configs
      // optionalAttrs (cfg.generalConfig != null) {
        "icingaweb2/config.ini".text = generators.toINI { } (defaultConfig // cfg.generalConfig);
      }
      // optionalAttrs (cfg.resources != null) {
        "icingaweb2/resources.ini".text = generators.toINI { } cfg.resources;
      }
      // optionalAttrs (cfg.authentications != null) {
        "icingaweb2/authentication.ini".text = generators.toINI { } cfg.authentications;
      }
      // optionalAttrs (cfg.groupBackends != null) {
        "icingaweb2/groups.ini".text = generators.toINI { } cfg.groupBackends;
      }
      // optionalAttrs (cfg.roles != null) {
        "icingaweb2/roles.ini".text = generators.toINI { } cfg.roles;
      };

    services.icingaweb2.libraryPaths = {
      ipl = pkgs.icingaweb2-ipl;
      thirdparty = pkgs.icingaweb2-thirdparty;
    };

    services.nginx = {
      enable = true;

      virtualHosts = mkIf (cfg.virtualHost != null) {
        ${cfg.virtualHost} = {
          extraConfig = ''
            index index.php;
            try_files $1 $uri $uri/ /index.php$is_args$args;
          '';

          locations."~ ..*/.*.php$".extraConfig = ''
            return 403;
          '';

          locations."~ ^/index.php(.*)$".extraConfig = ''
            fastcgi_intercept_errors on;
            fastcgi_index index.php;
            include ${config.services.nginx.package}/conf/fastcgi.conf;
            try_files $uri =404;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:${fpm.socket};
            fastcgi_param SCRIPT_FILENAME ${pkgs.icingaweb2}/public/index.php;
          '';

          root = "${pkgs.icingaweb2}/public";
        };
      };
    };

    services.phpfpm.pools = mkIf (cfg.pool == "${poolName}") {
      ${poolName} = {
        phpEnv = {
          ICINGAWEB_LIBDIR = toString (
            pkgs.linkFarm "icingaweb2-libdir" (
              mapAttrsToList (name: path: { inherit name path; }) cfg.libraryPaths
            )
          );
        };

        phpOptions = ''
          date.timezone = "${cfg.timezone}"
        '';

        phpPackage = pkgs.php83.withExtensions ({ all, enabled }: [ all.imagick ] ++ enabled);

        settings = mapAttrs (name: mkDefault) {
          "listen.group" = config.services.nginx.group;
          "listen.mode" = "0600";
          "listen.owner" = config.services.nginx.user;
          "pm" = "dynamic";
          "pm.max_children" = 75;
          "pm.max_spare_servers" = 10;
          "pm.min_spare_servers" = 2;
          "pm.start_servers" = 2;
        };

        user = "icingaweb2";
      };
    };

    systemd.services."phpfpm-${poolName}".serviceConfig.ReadWritePaths = [ "/etc/icingaweb2" ];
    # User and group
    users.groups.icingaweb2 = { };

    users.users.icingaweb2 = {
      description = "Icingaweb2 service user";
      group = "icingaweb2";
      isSystemUser = true;
    };
  };

  meta.maintainers = with lib.maintainers; [
    das_j
    helsinki-Jo
  ];
}
