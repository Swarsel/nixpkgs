{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.leaps;
  stateDir = "/var/lib/leaps/";
in
{
  options = {
    services.leaps = {
      enable = lib.mkEnableOption "leaps, a pair programming service";

      address = lib.mkOption {
        default = "";
        description = "Hostname or IP-address to listen to. By default it will listen on all interfaces.";
        example = "127.0.0.1";
        type = lib.types.str;
      };

      path = lib.mkOption {
        default = "/";
        description = "Subdirectory used for reverse proxy setups";
        type = lib.types.path;
      };

      port = lib.mkOption {
        default = 8080;
        description = "A port where leaps listens for incoming http requests";
        type = lib.types.port;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.leaps = {
      after = [ "network.target" ];
      description = "leaps service";

      serviceConfig = {
        ExecStart = "${pkgs.leaps}/bin/leaps -path ${toString cfg.path} -address ${cfg.address}:${toString cfg.port}";
        Group = "leaps";
        PrivateTmp = true;
        Restart = "on-failure";
        User = "leaps";
        WorkingDirectory = stateDir;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users = {
      groups.leaps = {
        gid = config.ids.gids.leaps;
      };

      users.leaps = {
        createHome = true;
        description = "Leaps server user";
        group = "leaps";
        home = stateDir;
        uid = config.ids.uids.leaps;
      };
    };
  };
}
