{
  config,
  lib,
  pkgs,
  ...
}:
let
  json = pkgs.formats.json { };
  transitionType = lib.types.submodule {
    options.command = lib.mkOption {
      default = null;

      description = ''
        Command to run when this transition is taken.
        This is executed inline by `bonsaid` and blocks handling of any other events until completion.
        To perform the command asynchronously, specify it like `[ "setsid" "-f" "my-command" ]`.

        Only effects transitions with `type = "exec"`.
      '';

      type = lib.types.nullOr (lib.types.listOf lib.types.str);
    };

    options.delay_duration = lib.mkOption {
      default = null;

      description = ''
        Nanoseconds to wait after the previous state change before performing this transition.
        This can be placed at the same level as a `type = "event"` transition to achieve a
        timeout mechanism.

        Only effects transitions with `type = "delay"`.
      '';

      type = lib.types.nullOr lib.types.int;
    };

    options.event_name = lib.mkOption {
      default = null;

      description = ''
        Name of the event which should trigger this transition when received by `bonsaid`.
        Events are sent to `bonsaid` by running `bonsaictl -e <event_name>`.

        Only effects transitions with `type = "event"`.
      '';

      type = lib.types.nullOr lib.types.str;
    };

    options.transitions = lib.mkOption {
      default = [ ];

      description = ''
        List of transitions out of this state.
        If left empty, then this state is considered a terminal state and entering it will
        trigger an immediate transition back to the root state (after processing side effects).
      '';

      type = lib.types.listOf transitionType;
      visible = "shallow";
    };

    options.type = lib.mkOption {
      description = ''
        Type of transition. Determines how bonsaid interprets the other options in this transition.
      '';

      type = lib.types.enum [
        "delay"
        "event"
        "exec"
      ];
    };

    freeformType = json.type;
  };
  cfg = config.services.bonsaid;
in
{
  options.services.bonsaid = {
    enable = lib.mkEnableOption "bonsaid";
    package = lib.mkPackageOption pkgs "bonsai" { };

    configFile = lib.mkOption {
      description = ''
        Path to a .json file specifying the state transitions.
        You don't need to set this unless you prefer to provide the json file
        yourself instead of using the `settings` option.
      '';

      type = lib.types.path;
    };

    extraFlags = lib.mkOption {
      default = [ ];

      description = ''
        Extra flags to pass to `bonsaid`, such as `[ "-v" ]` to enable verbose logging.
      '';

      type = lib.types.listOf lib.types.str;
    };

    settings = lib.mkOption {
      description = ''
        State transition definitions. See the upstream [README](https://git.sr.ht/~stacyharper/bonsai)
        for extended documentation and a more complete example.
      '';

      example = [
        {
          event_name = "power_button_pressed";

          transitions = [
            {
              delay_duration = 600000000;

              transitions = [
                {
                  command = [
                    "swaymsg"
                    "--"
                    "output"
                    "*"
                    "power"
                    "off"
                  ];

                  # `transitions = []` marks this as a terminal state,
                  # so bonsai will return to the root state immediately after executing the above command.
                  transitions = [ ];
                  type = "exec";
                }
              ];

              # Hold power button for 600ms to trigger a command
              type = "delay";
            }
            {
              event_name = "power_button_released";
              transitions = [ ];
              # If the power button is released before the 600ms elapses, return to the root state.
              type = "event";
            }
          ];

          type = "event";
        }
      ];

      type = lib.types.listOf transitionType;
    };
  };

  config = lib.mkIf cfg.enable {
    # bonsaid is controlled by bonsaictl, so place the latter in the environment by default.
    # bonsaictl is typically invoked by scripts or a DE so this isn't strictly necessary,
    # but it's helpful while administering the service generally.
    environment.systemPackages = [ cfg.package ];

    services.bonsaid.configFile =
      let
        filterNulls =
          v:
          if lib.isAttrs v then
            lib.mapAttrs (_: filterNulls) (lib.filterAttrs (_: a: a != null) v)
          else if lib.isList v then
            lib.map filterNulls (lib.filter (a: a != null) v)
          else
            v;
      in
      lib.mkDefault (json.generate "bonsai_tree.json" (filterNulls cfg.settings));

    systemd.user.services.bonsaid = {
      description = "Bonsai Finite State Machine daemon";
      documentation = [ "https://git.sr.ht/~stacyharper/bonsai" ];

      serviceConfig = {
        ExecStart = lib.escapeShellArgs (
          [
            (lib.getExe' cfg.package "bonsaid")
            "-t"
            cfg.configFile
          ]
          ++ cfg.extraFlags
        );

        Restart = "on-failure";
        RestartSec = "5s";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ lib.maintainers.colinsane ];
}
