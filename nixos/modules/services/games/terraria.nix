{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.services.terraria;
  opt = options.services.terraria;
  worldSizeMap = {
    large = 3;
    medium = 2;
    small = 1;
  };
  valFlag =
    name: val:
    lib.optionalString (val != null) "-${name} \"${lib.escape [ "\\" "\"" ] (toString val)}\"";
  boolFlag = name: val: lib.optionalString val "-${name}";
  flags = [
    (valFlag "port" cfg.port)
    (valFlag "maxPlayers" cfg.maxPlayers)
    (valFlag "password" cfg.password)
    (valFlag "motd" cfg.messageOfTheDay)
    (valFlag "world" cfg.worldPath)
    (valFlag "autocreate" (builtins.getAttr cfg.autoCreatedWorldSize worldSizeMap))
    (valFlag "banlist" cfg.banListPath)
    (boolFlag "secure" cfg.secure)
    (boolFlag "noupnp" cfg.noUPnP)
  ];

  tmuxCmd = "${lib.getExe pkgs.tmux} -S ${lib.escapeShellArg cfg.dataDir}/terraria.sock";

  stopScript = pkgs.writeShellScript "terraria-stop" ''
    if ! [ -d "/proc/$1" ]; then
      exit 0
    fi

    lastline=$(${tmuxCmd} capture-pane -p | grep . | tail -n1)

    # If the service is not configured to auto-start a world, it will show the world selection prompt
    # If the last non-empty line on-screen starts with "Choose World", we know the prompt is open
    if [[ "$lastline" =~ ^'Choose World' ]]; then
      # In this case, nothing needs to be saved, so we can kill the process
      ${tmuxCmd} kill-session
    else
      # Otherwise, we send the `exit` command
      ${tmuxCmd} send-keys Enter exit Enter
    fi

    # Wait for the process to stop
    tail --pid="$1" -f /dev/null
  '';
in
{
  options = {
    services.terraria = {
      enable = lib.mkOption {
        default = false;

        description = ''
          If enabled, starts a Terraria server. The server can be connected to via `tmux -S ''${config.${opt.dataDir}}/terraria.sock attach`
          for administration by users who are a part of the `terraria` group (use `C-b d` shortcut to detach again).
        '';

        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "terraria" {
        default = "terraria-server";
      };

      autoCreatedWorldSize = lib.mkOption {
        default = "medium";

        description = ''
          Specifies the size of the auto-created world if `worldPath` does not
          point to an existing world.
        '';

        type = lib.types.enum [
          "small"
          "medium"
          "large"
        ];
      };

      banListPath = lib.mkOption {
        default = null;

        description = ''
          The path to the ban list.
        '';

        type = lib.types.nullOr lib.types.path;
      };

      dataDir = lib.mkOption {
        default = "/var/lib/terraria";
        description = "Path to variable state data directory for terraria.";
        example = "/srv/terraria";
        type = lib.types.str;
      };

      maxPlayers = lib.mkOption {
        default = 255;

        description = ''
          Sets the max number of players (between 1 and 255).
        '';

        type = lib.types.ints.u8;
      };

      messageOfTheDay = lib.mkOption {
        default = null;

        description = ''
          Set the server message of the day text.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      noUPnP = lib.mkOption {
        default = false;
        description = "Disables automatic Universal Plug and Play.";
        type = lib.types.bool;
      };

      openFirewall = lib.mkOption {
        default = false;
        description = "Whether to open ports in the firewall";
        type = lib.types.bool;
      };

      password = lib.mkOption {
        default = null;

        description = ''
          Sets the server password. Leave `null` for no password.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      port = lib.mkOption {
        default = 7777;

        description = ''
          Specifies the port to listen on.
        '';

        type = lib.types.port;
      };

      secure = lib.mkOption {
        default = false;
        description = "Adds additional cheat protection to the server.";
        type = lib.types.bool;
      };

      worldPath = lib.mkOption {
        default = null;

        description = ''
          The path to the world file (`.wld`) which should be loaded.
          If no world exists at this path, one will be created with the size
          specified by `autoCreatedWorldSize`.
        '';

        type = lib.types.nullOr lib.types.path;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };

    systemd.services.terraria = {
      after = [ "network.target" ];
      description = "Terraria Server Service";

      serviceConfig = {
        ExecStart = "${tmuxCmd} new -d ${lib.getExe cfg.package} ${lib.concatStringsSep " " flags}";
        ExecStop = "${stopScript} $MAINPID";
        Group = "terraria";
        GuessMainPID = true;
        Type = "forking";
        UMask = 7;
        User = "terraria";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.terraria = {
      gid = config.ids.gids.terraria;
    };

    users.users.terraria = {
      createHome = true;
      description = "Terraria server service user";
      group = "terraria";
      home = cfg.dataDir;
      uid = config.ids.uids.terraria;
    };

  };
}
