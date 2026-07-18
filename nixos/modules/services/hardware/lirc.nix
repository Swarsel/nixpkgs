{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.lirc;
in
{

  ###### interface

  options = {
    services.lirc = {

      options = lib.mkOption {
        description = "LIRC default options described in man:lircd(8) ({file}`lirc_options.conf`)";

        example = ''
          [lircd]
          nodaemon = False
        '';

        type = lib.types.lines;
      };

      enable = lib.mkEnableOption "the LIRC daemon, to receive and send infrared signals";

      configs = lib.mkOption {
        description = "Configurations for lircd to load, see man:lircd.conf(5) for details ({file}`lircd.conf`)";
        type = lib.types.listOf lib.types.lines;
      };

      extraArguments = lib.mkOption {
        default = [ ];
        description = "Extra arguments to lircd.";
        type = lib.types.listOf lib.types.str;
      };
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    # Note: LIRC executables raises a warning, if lirc_options.conf does not exist
    environment.etc."lirc/lirc_options.conf".text = cfg.options;
    environment.systemPackages = [ pkgs.lirc ];
    passthru.lirc.socket = "/run/lirc/lircd";

    systemd.services.lircd =
      let
        configFile = pkgs.writeText "lircd.conf" (builtins.concatStringsSep "\n" cfg.configs);
      in
      {
        after = [ "network.target" ];
        description = "LIRC daemon service";

        serviceConfig = {
          ExecStart = ''
            ${pkgs.lirc}/bin/lircd --nodaemon \
              ${lib.escapeShellArgs cfg.extraArguments} \
              ${configFile}
          '';

          ExecStartPre = [
            "${pkgs.coreutils}/bin/chown lirc /run/lirc/"
          ];

          # 2. fix runtime folder owner-ship, happens when socket activation
          #    creates the folder
          PermissionsStartOnly = true;

          RuntimeDirectory = [
            "lirc"
            "lirc/lock"
          ];

          # Service runtime directory and socket share same folder.
          # Following hacks are necessary to get everything right:
          # 1. prevent socket deletion during stop and restart
          RuntimeDirectoryPreserve = true;
          User = "lirc";
        };

        unitConfig.Documentation = [ "man:lircd(8)" ];
      };

    systemd.sockets.lircd = {
      description = "LIRC daemon socket";

      socketConfig = {
        ListenStream = config.passthru.lirc.socket;
        SocketMode = "0660";
        SocketUser = "lirc";
      };

      wantedBy = [ "sockets.target" ];
    };

    users.groups.lirc.gid = config.ids.gids.lirc;

    users.users.lirc = {
      description = "LIRC user for lircd";
      group = "lirc";
      uid = config.ids.uids.lirc;
    };
  };
}
