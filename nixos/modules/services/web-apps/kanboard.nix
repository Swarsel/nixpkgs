{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.kanboard;

  toStringAttrs = lib.mapAttrs (lib.const toString);
in
{
  options.services.kanboard = {
    enable = lib.mkEnableOption "Kanboard";
    package = lib.mkPackageOption pkgs "kanboard" { };

    dataDir = lib.mkOption {
      default = "/var/lib/kanboard";
      description = "Default data folder for Kanboard.";
      example = "/mnt/kanboard";
      type = lib.types.str;
    };

    # Nginx
    domain = lib.mkOption {
      default = "kanboard";
      description = "FQDN for the Kanboard instance.";
      example = "kanboard.example.org";
      type = lib.types.str;
    };

    group = lib.mkOption {
      default = "kanboard";
      description = "Group under which Kanboard runs.";
      type = lib.types.str;
    };

    nginx = lib.mkOption {
      default = { };

      description = ''
        With this option, you can customize an NGINX virtual host which already
        has sensible defaults for Kanboard. Set to `{ }` if you do not need any
        customization for the virtual host. If enabled, then by default, the
        {option}`serverName` is `''${domain}`. If this is set to null (the
        default), no NGINX virtual host will be configured.
      '';

      example = lib.literalExpression ''
        {
          enableACME = true;
          forceSSL = true;
        }
      '';

      type = lib.types.nullOr (
        lib.types.submodule (import ../web-servers/nginx/vhost-options.nix { inherit config lib; })
      );
    };

    phpfpm.settings = lib.mkOption {
      default = { };

      description = ''
        Options for kanboard's PHPFPM pool.
      '';

      type =
        with lib.types;
        attrsOf (oneOf [
          int
          str
          bool
        ]);
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Customize the default settings, refer to <https://github.com/kanboard/kanboard/blob/main/config.default.php>
        for details on supported values.
      '';

      type =
        with lib.types;
        attrsOf (oneOf [
          str
          int
          bool
        ]);
    };

    user = lib.mkOption {
      default = "kanboard";
      description = "User under which Kanboard runs.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = lib.mkIf (cfg.nginx != null) {
      enable = lib.mkDefault true;

      virtualHosts."${cfg.domain}" = lib.mkMerge [
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
            fastcgi_pass unix:${config.services.phpfpm.pools.kanboard.socket};
            include ${config.services.nginx.package}/conf/fastcgi.conf;
            include ${config.services.nginx.package}/conf/fastcgi_params;
          '';

          root = lib.mkForce "${cfg.package}/share/kanboard";
        }
        cfg.nginx
      ];
    };

    services.phpfpm.pools.kanboard = {
      group = cfg.group;

      phpEnv = lib.mkMerge [
        { DATA_DIR = cfg.dataDir; }
        (toStringAttrs cfg.settings)
      ];

      settings = lib.mkMerge [
        {
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
        }
        cfg.phpfpm.settings
      ];

      user = cfg.user;
    };

    users = {
      groups = lib.mkIf (cfg.group == "kanboard") {
        kanboard = { };
      };

      users = lib.mkIf (cfg.user == "kanboard") {
        kanboard = {
          createHome = true;
          group = cfg.group;
          home = cfg.dataDir;
          isSystemUser = true;
        };
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ yzx9 ];
}
