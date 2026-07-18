{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.xscreensaver;
in
{
  options.services.xscreensaver = {
    enable = lib.mkEnableOption "xscreensaver user service";
    package = lib.mkPackageOption pkgs "xscreensaver" { };

    hooks = lib.mkOption {
      default = { };
      defaultText = lib.literalExpression "{ }";

      description = ''
        An attrset of events and commands to run upon each event.
        Refer to <https://www.jwz.org/xscreensaver/man3.html> for supported events.
      '';

      example = lib.literalExpression ''
        # Reconfigure autorandr on screen wake up
        {
          "RUN" = "''${lib.getExe pkgs.autorandr} --change --ignore-lid";
        };
      '';

      type = with lib.types; attrsOf lines;
    };
  };

  config = lib.mkIf cfg.enable {
    # Make xscreensaver-auth setuid root so that it can (try to) prevent the OOM
    # killer from unlocking the screen.
    security.wrappers.xscreensaver-auth = {
      group = "root";
      owner = "root";
      setuid = true;
      source = "${pkgs.xscreensaver}/libexec/xscreensaver/xscreensaver-auth";
    };

    systemd.user.services = {
      xscreensaver = {
        enable = true;
        after = [ "graphical-session-pre.target" ];
        description = "XScreenSaver";
        partOf = [ "graphical-session.target" ];
        path = [ cfg.package ];
        serviceConfig.ExecStart = "${cfg.package}/bin/xscreensaver -no-splash";
        wantedBy = [ "graphical-session.target" ];
      };

      xscreensaver-hooks = lib.mkIf (cfg.enable && cfg.hooks != { }) {
        enable = true;

        after = [
          "graphical-session.target"
          "xscreensaver.service"
        ];

        description = "Run commands on XScreenSaver events";
        partOf = [ "graphical-session.target" ];
        path = [ cfg.package ];

        script =
          let
            handlers = lib.concatMapAttrsStringSep "\n" (event: action: ''
              "${event}")
                      ( ${action}
                      )
                      ;;
            '') cfg.hooks;
          in
          ''
            xscreensaver-command -watch | while read event rest; do
              echo "XScreenSaver handler script got \"$event\""
              case $event in
                ${handlers}
              esac
            done
          '';

        serviceConfig = {
          Restart = "always";
        };

        wantedBy = [ "graphical-session.target" ];
      };
    };
  };

  meta.maintainers = with lib.maintainers; [
    vancluever
  ];
}
