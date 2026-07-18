{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.lxd-image-server;
  format = pkgs.formats.toml { };

  location = "/var/www/simplestreams";
in
{
  options = {
    services.lxd-image-server = {
      enable = lib.mkEnableOption "lxd-image-server";

      group = lib.mkOption {
        default = "nginx";
        description = "Group assigned to the user and the webroot directory.";
        example = "www-data";
        type = lib.types.str;
      };

      nginx = {
        enable = lib.mkEnableOption "nginx";

        domain = lib.mkOption {
          description = "Domain to use for nginx virtual host.";
          example = "images.example.org";
          type = lib.types.str;
        };
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Configuration for lxd-image-server.

          Example see <https://github.com/Avature/lxd-image-server/blob/master/config.toml>.
        '';

        type = format.type;
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable) {
      environment.etc."lxd-image-server/config.toml".source = format.generate "config.toml" cfg.settings;

      services.logrotate.settings.lxd-image-server = {
        compress = true;
        copytruncate = true;
        create = "755 lxd-image-server ${cfg.group}";
        delaycompress = true;
        files = "/var/log/lxd-image-server/lxd-image-server.log";
        frequency = "daily";
        rotate = 21;
      };

      systemd.services.lxd-image-server = {
        after = [ "network.target" ];
        description = "LXD Image Server";
        reloadTriggers = [ config.environment.etc."lxd-image-server/config.toml".source ];

        serviceConfig = {
          DynamicUser = true;
          ExecReload = "${pkgs.lxd-image-server}/bin/lxd-image-server reload";
          ExecStart = "${pkgs.lxd-image-server}/bin/lxd-image-server watch";
          ExecStartPre = "${pkgs.lxd-image-server}/bin/lxd-image-server init";
          Group = cfg.group;
          LogsDirectory = "lxd-image-server";
          ReadWritePaths = [ location ];
          RuntimeDirectory = "lxd-image-server";
          User = "lxd-image-server";
        };

        wantedBy = [ "multi-user.target" ];
      };

      systemd.tmpfiles.rules = [
        "d /var/www/simplestreams 0755 lxd-image-server ${cfg.group}"
      ];

      users.groups.${cfg.group} = { };

      users.users.lxd-image-server = {
        group = cfg.group;
        isSystemUser = true;
      };
    })
    # this is separate so it can be enabled on mirrored hosts
    (lib.mkIf (cfg.nginx.enable) {
      # https://github.com/Avature/lxd-image-server/blob/master/resources/nginx/includes/lxd-image-server.pkg.conf
      services.nginx.virtualHosts = {
        "${cfg.nginx.domain}" = {
          enableACME = lib.mkDefault true;
          forceSSL = true;

          locations = {
            "/streams/v1/" = {
              index = "index.json";
            };

            # Serve json files with content type header application/json
            "~ \\.json$" = {
              extraConfig = ''
                add_header Content-Type application/json;
              '';
            };

            "~ \\.tar.gz$" = {
              extraConfig = ''
                add_header Content-Type application/octet-stream;
              '';
            };

            "~ \\.tar.xz$" = {
              extraConfig = ''
                add_header Content-Type application/octet-stream;
              '';
            };

            # Deny access to document root and the images folder
            "~ ^/(images/)?$" = {
              return = "403";
            };
          };

          root = location;
        };
      };
    })
  ];
}
