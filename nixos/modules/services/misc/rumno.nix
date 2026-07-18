{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.rumno;
in
{
  options.services.rumno = {
    enable = lib.mkEnableOption "rumno visual pop-up notification manager";
    package = lib.mkPackageOption pkgs "rumno" { };

    extraArgs = lib.mkOption {
      default = [ ];

      description = ''
        Extra command-line arguments to pass to the rumno daemon.
      '';

      example = [
        "--verbose"
        "--config"
        "/etc/rumno/config.toml"
      ];

      type = lib.types.listOf lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure dbus service file is installed
    environment.systemPackages = [ cfg.package ];

    systemd.user.services.rumno = {
      after = [ "graphical-session-pre.target" ];
      description = "Rumno visual pop-up notification manager";

      environment = {
        # Set GTK theme environment variables if needed
        GTK_THEME = lib.mkDefault "";
      };

      partOf = [ "graphical-session.target" ];

      serviceConfig = {
        BusName = "de.rumno.v1";
        ExecStart = "${cfg.package}/bin/rumno daemon --foreground ${lib.escapeShellArgs cfg.extraArgs}";

        # Environment for GTK/GUI applications
        PassEnvironment = [
          "DISPLAY"
          "WAYLAND_DISPLAY"
          "XDG_RUNTIME_DIR"
        ];

        Restart = "on-failure";
        RestartSec = 1;
        Type = "dbus";
      };

      wantedBy = [ "graphical-session.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ imalison ];
}
