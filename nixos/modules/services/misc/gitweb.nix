{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.gitweb;
  cfgNginx = config.services.gitweb.nginx;
  package = pkgs.gitweb.override (
    lib.optionalAttrs cfg.gitwebTheme {
      gitwebTheme = true;
    }
  );
in
{

  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "nginx" "gitweb" "enable" ]
      [ "services" "gitweb" "nginx" "enable" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "nginx" "gitweb" "location" ]
      [ "services" "gitweb" "nginx" "location" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "nginx" "gitweb" "user" ]
      [ "services" "gitweb" "nginx" "user" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "nginx" "gitweb" "group" ]
      [ "services" "gitweb" "nginx" "group" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "nginx" "gitweb" "virtualHost" ]
      [ "services" "gitweb" "nginx" "virtualHost" ]
    )
  ];

  options.services.gitweb = {

    extraConfig = lib.mkOption {
      default = "";

      description = ''
        Verbatim configuration text appended to the generated gitweb.conf file.
      '';

      example = ''
        $feature{'highlight'}{'default'} = [1];
        $feature{'ctags'}{'default'} = [1];
        $feature{'avatar'}{'default'} = ['gravatar'];
      '';

      type = lib.types.lines;
    };

    gitwebConfigFile = lib.mkOption {
      default = pkgs.writeText "gitweb.conf" ''
        # path to git projects (<project>.git)
        $projectroot = "${cfg.projectroot}";
        $highlight_bin = "${pkgs.highlight}/bin/highlight";
        ${cfg.extraConfig}
      '';

      defaultText = lib.literalMD "generated config file";
      internal = true;
      readOnly = true;
      type = lib.types.path;
    };

    gitwebTheme = lib.mkOption {
      default = false;

      description = ''
        Use an alternative theme for gitweb, strongly inspired by GitHub.
      '';

      type = lib.types.bool;
    };

    nginx = {
      enable = lib.mkOption {
        default = false;

        description = ''
          If true, enable gitweb in nginx.
        '';

        type = lib.types.bool;
      };

      group = lib.mkOption {
        default = "nginx";

        description = ''
          Group that the CGI process will belong to. (Set to `config.services.gitolite.group` if you are using gitolite.)
        '';

        type = lib.types.str;
      };

      location = lib.mkOption {
        default = "/gitweb";

        description = ''
          Location to serve gitweb on.
        '';

        type = lib.types.str;
      };

      user = lib.mkOption {
        default = "nginx";

        description = ''
          Existing user that the CGI process will belong to. (Default almost surely will do.)
        '';

        type = lib.types.str;
      };

      virtualHost = lib.mkOption {
        default = "_";

        description = ''
          VirtualHost to serve gitweb on. Default is catch-all.
        '';

        type = lib.types.str;
      };
    };

    projectroot = lib.mkOption {
      default = "/srv/git";

      description = ''
        Path to git projects (bare repositories) that should be served by
        gitweb. Must not end with a slash.
      '';

      type = lib.types.path;
    };

  };

  config = lib.mkIf cfgNginx.enable {

    services.nginx = {
      virtualHosts.${cfgNginx.virtualHost} = {
        locations."${cfgNginx.location}/" = {
          extraConfig = ''
            include ${config.services.nginx.package}/conf/fastcgi_params;
            fastcgi_param GITWEB_CONFIG ${cfg.gitwebConfigFile};
            fastcgi_pass unix:/run/gitweb/gitweb.sock;
          '';
        };

        locations."${cfgNginx.location}/static/" = {
          alias = "${package}/static/";
        };
      };
    };

    systemd.services.gitweb = {
      description = "GitWeb service";

      environment = {
        FCGI_SOCKET_PATH = "/run/gitweb/gitweb.sock";
      };

      script = "${package}/gitweb.cgi --fastcgi --nproc=1";

      serviceConfig = {
        Group = cfgNginx.group;
        RuntimeDirectory = [ "gitweb" ];
        User = cfgNginx.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

  };

  meta.maintainers = [ ];

}
