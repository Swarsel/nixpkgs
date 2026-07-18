{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.cpupower-gui;
in
{
  options = {
    services.cpupower-gui = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Enables dbus/systemd service needed by cpupower-gui.
          These services are responsible for retrieving and modifying cpu power
          saving settings.
        '';

        example = true;
        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.cpupower-gui ];
    services.dbus.packages = [ pkgs.cpupower-gui ];

    systemd.services = {
      cpupower-gui = {
        description = "Apply cpupower-gui config at boot";

        serviceConfig = {
          ExecStart = "${pkgs.cpupower-gui}/bin/cpupower-gui config";
          Type = "oneshot";
        };

        wantedBy = [ "multi-user.target" ];
      };

      cpupower-gui-helper = {
        aliases = [ "dbus-org.rnd2.cpupower_gui.helper.service" ];
        description = "cpupower-gui system helper";

        serviceConfig = {
          BusName = "org.rnd2.cpupower_gui.helper";
          ExecStart = "${pkgs.cpupower-gui}/lib/cpupower-gui/cpupower-gui-helper";
          Type = "dbus";
        };
      };
    };

    systemd.user = {
      services.cpupower-gui-user = {
        description = "Apply cpupower-gui config at user login";

        serviceConfig = {
          ExecStart = "${pkgs.cpupower-gui}/bin/cpupower-gui config";
          Type = "oneshot";
        };

        wantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
