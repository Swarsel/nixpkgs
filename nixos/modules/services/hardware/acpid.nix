{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.acpid;

  canonicalHandlers = {
    acEvent = {
      action = cfg.acEventCommands;
      event = "ac_adapter.*";
    };

    lidEvent = {
      action = cfg.lidEventCommands;
      event = "button/lid.*";
    };

    powerEvent = {
      action = cfg.powerEventCommands;
      event = "button/power.*";
    };
  };

  acpiConfDir = pkgs.runCommand "acpi-events" { preferLocalBuild = true; } ''
    mkdir -p $out
    ${
      # Generate a configuration file for each event. (You can't have
      # multiple events in one config file...)
      let
        f = name: handler: ''
          fn=$out/${name}
          echo "event=${handler.event}" > $fn
          echo "action=${pkgs.writeShellScriptBin "${name}.sh" handler.action}/bin/${name}.sh '%e'" >> $fn
        '';
      in
      lib.concatStringsSep "\n" (lib.mapAttrsToList f (canonicalHandlers // cfg.handlers))
    }
  '';

in

{

  ###### interface

  options = {

    services.acpid = {

      enable = lib.mkEnableOption "the ACPI daemon";

      acEventCommands = lib.mkOption {
        default = "";
        description = "Shell commands to execute on an ac_adapter.* event.";
        type = lib.types.lines;
      };

      handlers = lib.mkOption {
        default = { };

        description = ''
          Event handlers.

          ::: {.note}
          Handler can be a single command.
          :::
        '';

        example = {
          ac-power = {
            action = ''
              vals=($1)  # space separated string to array of multiple values
              case ''${vals[3]} in
                  00000000)
                      echo unplugged >> /tmp/acpi.log
                      ;;
                  00000001)
                      echo plugged in >> /tmp/acpi.log
                      ;;
                  *)
                      echo unknown >> /tmp/acpi.log
                      ;;
              esac
            '';

            event = "ac_adapter/*";
          };
        };

        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              action = lib.mkOption {
                description = "Shell commands to execute when the event is triggered.";
                type = lib.types.lines;
              };

              event = lib.mkOption {
                description = "Event type.";
                example = lib.literalExpression ''"button/power.*" "button/lid.*" "ac_adapter.*" "button/mute.*" "button/volumedown.*" "cd/play.*" "cd/next.*"'';
                type = lib.types.str;
              };
            };
          }
        );
      };

      lidEventCommands = lib.mkOption {
        default = "";
        description = "Shell commands to execute on a button/lid.* event.";
        type = lib.types.lines;
      };

      logEvents = lib.mkOption {
        default = false;
        description = "Log all event activity.";
        type = lib.types.bool;
      };

      powerEventCommands = lib.mkOption {
        default = "";
        description = "Shell commands to execute on a button/power.* event.";
        type = lib.types.lines;
      };

    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    systemd.services.acpid = {
      description = "ACPI Daemon";
      documentation = [ "man:acpid(8)" ];

      serviceConfig = {
        ExecStart = lib.escapeShellArgs (
          [
            "${pkgs.acpid}/bin/acpid"
            "--foreground"
            "--netlink"
            "--confdir"
            "${acpiConfDir}"
          ]
          ++ lib.optional cfg.logEvents "--logevents"
        );
      };

      unitConfig = {
        ConditionPathExists = [ "/proc/acpi" ];
        ConditionVirtualization = "!systemd-nspawn";
      };

      wantedBy = [ "multi-user.target" ];

    };

  };

}
