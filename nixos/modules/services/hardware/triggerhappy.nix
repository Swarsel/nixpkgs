{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.triggerhappy;

  socket = "/run/thd.socket";

  configFile = pkgs.writeText "triggerhappy.conf" ''
    ${lib.concatMapStringsSep "\n" (
      {
        cmd,
        event,
        keys,
        ...
      }:
      "${lib.concatMapStringsSep "+" (x: "KEY_" + x) keys} ${
        toString
          {
            hold = 2;
            press = 1;
            release = 0;
          }
          .${event}
      } ${cmd}"
    ) cfg.bindings}
    ${cfg.extraConfig}
  '';

  bindingCfg =
    { ... }:
    {
      options = {

        cmd = lib.mkOption {
          description = "What to run.";
          type = lib.types.str;
        };

        event = lib.mkOption {
          default = "press";
          description = "Event to match.";

          type = lib.types.enum [
            "press"
            "hold"
            "release"
          ];
        };

        keys = lib.mkOption {
          description = "List of keys to match.  Key names as defined in linux/input-event-codes.h";
          type = lib.types.listOf lib.types.str;
        };

      };
    };

in

{

  ###### interface

  options = {

    services.triggerhappy = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable the {command}`triggerhappy` hotkey daemon.
        '';

        type = lib.types.bool;
      };

      bindings = lib.mkOption {
        default = [ ];

        description = ''
          Key bindings for {command}`triggerhappy`.
        '';

        example = lib.literalExpression ''
          [ { keys = ["PLAYPAUSE"];  cmd = "''${lib.getExe pkgs.mpc} -q toggle"; } ]
        '';

        type = lib.types.listOf (lib.types.submodule bindingCfg);
      };

      extraConfig = lib.mkOption {
        default = "";

        description = ''
          Literal contents to append to the end of {command}`triggerhappy` configuration file.
        '';

        type = lib.types.lines;
      };

      user = lib.mkOption {
        default = "nobody";

        description = ''
          User account under which {command}`triggerhappy` runs.
        '';

        example = "root";
        type = lib.types.str;
      };

    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    services.udev.packages = lib.singleton (
      pkgs.writeTextFile {
        destination = "/etc/udev/rules.d/61-triggerhappy.rules";
        name = "triggerhappy-udev-rules";

        text = ''
          ACTION=="add", SUBSYSTEM=="input", KERNEL=="event[0-9]*", ATTRS{name}!="triggerhappy", \
            RUN+="${pkgs.triggerhappy}/bin/th-cmd --socket ${socket} --passfd --udev"
        '';
      }
    );

    systemd.services.triggerhappy = {
      description = "Global hotkey daemon";
      documentation = [ "man:thd(1)" ];

      serviceConfig = {
        ExecStart = "${pkgs.triggerhappy}/bin/thd ${
          lib.optionalString (cfg.user != "root") "--user ${cfg.user}"
        } --socket ${socket} --triggers ${configFile} --deviceglob /dev/input/event*";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.sockets.triggerhappy = {
      description = "Triggerhappy Socket";
      socketConfig.ListenDatagram = socket;
      wantedBy = [ "sockets.target" ];
    };

  };

}
