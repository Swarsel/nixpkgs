{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.u9fs;
in
{

  options = {

    services.u9fs = {

      enable = lib.mkOption {
        default = false;
        description = "Whether to run the u9fs 9P server for Unix.";
        type = lib.types.bool;
      };

      extraArgs = lib.mkOption {
        default = "";

        description = ''
          Extra arguments to pass on invocation,
          see {command}`man 4 u9fs`
        '';

        example = "-a none";
        type = lib.types.str;
      };

      listenStreams = lib.mkOption {
        default = [ "564" ];

        description = ''
          Sockets to listen for clients on.
          See {command}`man 5 systemd.socket` for socket syntax.
        '';

        example = [ "192.168.16.1:564" ];
        type = lib.types.listOf lib.types.str;
      };

      user = lib.mkOption {
        default = "nobody";
        description = "User to run u9fs under.";
        type = lib.types.str;
      };

    };

  };

  config = lib.mkIf cfg.enable {

    systemd = {
      services."u9fs@" = {
        description = "9P Protocol Server";
        reloadIfChanged = true;
        requires = [ "u9fs.socket" ];

        serviceConfig = {
          AmbientCapabilities = "cap_setuid cap_setgid";
          ExecStart = "-${pkgs.u9fs}/bin/u9fs ${cfg.extraArgs}";
          StandardError = "journal";
          StandardInput = "socket";
          User = cfg.user;
        };
      };

      sockets.u9fs = {
        inherit (cfg) listenStreams;
        after = [ "network.target" ];
        description = "U9fs Listening Socket";
        socketConfig.Accept = "yes";
        wantedBy = [ "sockets.target" ];
      };
    };

  };

}
