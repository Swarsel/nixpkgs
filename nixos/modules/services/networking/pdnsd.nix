{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.pdnsd;
  pdnsd = pkgs.pdnsd;
  pdnsdUser = "pdnsd";
  pdnsdGroup = "pdnsd";
  pdnsdConf = pkgs.writeText "pdnsd.conf" ''
    global {
      run_as=${pdnsdUser};
      cache_dir="${cfg.cacheDir}";
      ${cfg.globalConfig}
    }

    server {
      ${cfg.serverConfig}
    }
    ${cfg.extraConfig}
  '';
in

{
  options = {
    services.pdnsd = {
      enable = mkEnableOption "pdnsd";

      cacheDir = mkOption {
        default = "/var/cache/pdnsd";
        description = "Directory holding the pdnsd cache";
        type = types.str;
      };

      extraConfig = mkOption {
        default = "";

        description = ''
          Extra configuration directives that should be added to
          {file}`pdnsd.conf`.
        '';

        type = types.lines;
      };

      globalConfig = mkOption {
        default = "";

        description = ''
          Global configuration that should be added to the global directory
          of {file}`pdnsd.conf`.
        '';

        type = types.lines;
      };

      serverConfig = mkOption {
        default = "";

        description = ''
          Server configuration that should be added to the server directory
          of {file}`pdnsd.conf`.
        '';

        type = types.lines;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.pdnsd = {
      after = [ "network.target" ];
      description = "pdnsd";

      preStart = ''
        mkdir -p "${cfg.cacheDir}"
        touch "${cfg.cacheDir}/pdnsd.cache"
        chown -R ${pdnsdUser}:${pdnsdGroup} "${cfg.cacheDir}"
      '';

      serviceConfig = {
        ExecStart = "${pdnsd}/bin/pdnsd -c ${pdnsdConf}";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.${pdnsdGroup} = {
      gid = config.ids.gids.pdnsd;
    };

    users.users.${pdnsdUser} = {
      description = "pdnsd user";
      group = pdnsdGroup;
      uid = config.ids.uids.pdnsd;
    };
  };
}
