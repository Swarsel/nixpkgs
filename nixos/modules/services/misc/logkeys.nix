{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.logkeys;
in
{
  options.services.logkeys = {
    enable = lib.mkEnableOption "logkeys, a keylogger service";

    device = lib.mkOption {
      default = null;
      description = "Use the given device as keyboard input event device instead of /dev/input/eventX default.";
      example = "/dev/input/event15";
      type = lib.types.nullOr lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.logkeys = {
      description = "LogKeys Keylogger Daemon";

      serviceConfig = {
        ExecStart = "${pkgs.logkeys}/bin/logkeys -s${
          lib.optionalString (cfg.device != null) " -d ${cfg.device}"
        }";

        ExecStop = "${pkgs.logkeys}/bin/logkeys -k";
        Type = "forking";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
