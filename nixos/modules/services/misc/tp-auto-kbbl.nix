{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.tp-auto-kbbl;

in
{
  options = {
    services.tp-auto-kbbl = {
      enable = lib.mkEnableOption "auto toggle keyboard back-lighting on Thinkpads (and maybe other laptops) for Linux";
      package = lib.mkPackageOption pkgs "tp-auto-kbbl" { };

      arguments = lib.mkOption {
        default = [ ];

        description = ''
          List of arguments appended to `./tp-auto-kbbl --device [device] [arguments]`
        '';

        type = lib.types.listOf lib.types.str;
      };

      device = lib.mkOption {
        default = "/dev/input/event0";
        description = "Device watched for activities.";
        type = lib.types.str;
      };

    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    services.upower.enable = true;

    systemd.services.tp-auto-kbbl = {
      serviceConfig = {
        ExecStart = lib.concatStringsSep " " (
          [
            "${cfg.package}/bin/tp-auto-kbbl"
            "--device ${cfg.device}"
          ]
          ++ cfg.arguments
        );

        Restart = "always";
        Type = "simple";
      };

      unitConfig = {
        After = [ "dbus.service" ];
        Description = "Auto toggle keyboard backlight";
        Documentation = "https://github.com/saibotd/tp-auto-kbbl";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ ];
}
