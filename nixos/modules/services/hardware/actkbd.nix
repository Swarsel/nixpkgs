{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.actkbd;

  configFile = pkgs.writeText "actkbd.conf" ''
    ${lib.concatMapStringsSep "\n" (
      {
        attributes,
        command,
        events,
        keys,
        ...
      }:
      "${
        lib.concatMapStringsSep "+" toString keys
      }:${lib.concatStringsSep "," events}:${lib.concatStringsSep "," attributes}:${command}"
    ) cfg.bindings}
    ${cfg.extraConfig}
  '';

  bindingCfg =
    { ... }:
    {
      options = {

        attributes = lib.mkOption {
          default = [ "exec" ];
          description = "List of attributes.";
          type = lib.types.listOf lib.types.str;
        };

        command = lib.mkOption {
          default = "";
          description = "What to run.";
          type = lib.types.str;
        };

        events = lib.mkOption {
          default = [ "key" ];
          description = "List of events to match.";

          type = lib.types.listOf (
            lib.types.enum [
              "key"
              "rep"
              "rel"
            ]
          );
        };

        keys = lib.mkOption {
          description = "List of keycodes to match.";
          type = lib.types.listOf lib.types.int;
        };

      };
    };

in

{

  ###### interface

  options = {

    services.actkbd = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable the {command}`actkbd` key mapping daemon.

          Turning this on will start an {command}`actkbd`
          instance for every evdev input that has at least one key
          (which is okay even for systems with tiny memory footprint,
          since actkbd normally uses \<100 bytes of memory per
          instance).

          This allows binding keys globally without the need for e.g.
          X11.
        '';

        type = lib.types.bool;
      };

      bindings = lib.mkOption {
        default = [ ];

        description = ''
          Key bindings for {command}`actkbd`.

          See {command}`actkbd` {file}`README` for documentation.

          The example shows a piece of what {option}`sound.mediaKeys.enable` does when enabled.
        '';

        example = lib.literalExpression ''
          [ { keys = [ 113 ]; events = [ "key" ]; command = "''${pkgs.alsa-utils}/bin/amixer -q set Master toggle"; }
          ]
        '';

        type = lib.types.listOf (lib.types.submodule bindingCfg);
      };

      extraConfig = lib.mkOption {
        default = "";

        description = ''
          Literal contents to append to the end of actkbd configuration file.
        '';

        type = lib.types.lines;
      };

    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    # For testing
    environment.systemPackages = [ pkgs.actkbd ];

    services.udev.packages = lib.singleton (
      pkgs.writeTextFile {
        destination = "/etc/udev/rules.d/61-actkbd.rules";
        name = "actkbd-udev-rules";

        text = ''
          ACTION=="add", SUBSYSTEM=="input", KERNEL=="event[0-9]*", ENV{ID_INPUT_KEY}=="1", TAG+="systemd", ENV{SYSTEMD_WANTS}+="actkbd@$env{DEVNAME}.service"
        '';
      }
    );

    systemd.services."actkbd@" = {
      enable = true;
      restartIfChanged = true;

      serviceConfig = {
        ExecStart = "${pkgs.actkbd}/bin/actkbd -D -c ${configFile} -d %I";
        Type = "forking";
      };

      unitConfig = {
        ConditionPathExists = "%I";
        Description = "actkbd on %I";
      };
    };

  };

}
