{
  config,
  lib,
  pkgs,
  ...
}:

let
  common-name = "baikal";
  cfg = config.services.baikal;
in
{
  options = {
    services.baikal = {
      enable = lib.mkEnableOption "baikal";
      package = lib.mkPackageOption pkgs "baikal" { };

      group = lib.mkOption {
        default = common-name;

        description = ''
          Group account under which the web-application run.
        '';

        type = lib.types.str;
      };

      phpPackage = lib.mkPackageOption pkgs "php" { };

      pool = lib.mkOption {
        default = common-name;

        description = ''
          Name of existing phpfpm pool that is used to run web-application.
          If not specified a pool will be created automatically with
          default values.
        '';

        type = lib.types.str;
      };

      user = lib.mkOption {
        default = common-name;

        description = ''
          User account under which the web-application run.
        '';

        type = lib.types.str;
      };

      virtualHost = lib.mkOption {
        default = common-name;

        description = ''
          Name of the nginx virtualhost to use and setup. If null, do not setup any virtualhost.
        '';

        type = lib.types.nullOr lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = lib.mkIf (cfg.virtualHost != null) {
      enable = true;

      virtualHosts."${cfg.virtualHost}" = {
        locations = {
          "/" = {
            index = "index.php";
          };

          "/.well-known/".extraConfig = ''
            rewrite ^/.well-known/caldav  /dav.php redirect;
            rewrite ^/.well-known/carddav /dav.php redirect;
          '';

          "~ /(\\.ht|Core|Specific|config)".extraConfig = ''
            deny all;
            return 404;
          '';

          "~ ^(.+\\.php)(.*)$".extraConfig = ''
            try_files $fastcgi_script_name =404;
            include                   ${config.services.nginx.package}/conf/fastcgi.conf;
            fastcgi_split_path_info   ^(.+\.php)(.*)$;
            fastcgi_pass              unix:${config.services.phpfpm.pools.${cfg.pool}.socket};
            fastcgi_param             SCRIPT_FILENAME  $document_root$fastcgi_script_name;
            fastcgi_param             PATH_INFO        $fastcgi_path_info;
          '';
        };

        root = "${cfg.package}/share/php/baikal/html";
      };
    };

    services.phpfpm.pools = lib.mkIf (cfg.pool == "${common-name}") {
      ${common-name} = {
        inherit (cfg) user phpPackage;

        phpEnv = {
          "BAIKAL_PATH_CONFIG" = "/var/lib/baikal/config/";
          "BAIKAL_PATH_SPECIFIC" = "/var/lib/baikal/specific/";
        };

        settings = lib.mapAttrs (name: lib.mkDefault) {
          "catch_workers_output" = 1;
          "listen.group" = config.services.nginx.group;
          "listen.mode" = "0600";
          "listen.owner" = config.services.nginx.user;
          "pm" = "dynamic";
          "pm.max_children" = 75;
          "pm.max_requests" = 500;
          "pm.max_spare_servers" = 4;
          "pm.min_spare_servers" = 1;
          "pm.process_idle_timeout" = 30;
          "pm.start_servers" = 1;
        };
      };
    };

    systemd.tmpfiles.settings."baikal" = builtins.listToAttrs (
      map
        (x: {
          name = "/var/lib/baikal/${x}";

          value.d = {
            inherit (cfg) user group;
            mode = "0700";
          };
        })
        [
          "config"
          "specific"
          "specific/db"
        ]
    );

    users.groups.${cfg.group} = lib.mkIf (cfg.group == common-name) { };

    users.users.${cfg.user} = lib.mkIf (cfg.user == common-name) {
      inherit (cfg) group;
      description = "baikal service user";
      isSystemUser = true;
    };
  };

  meta.maintainers = [ lib.maintainers.wrvsrx ];
}
