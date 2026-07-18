{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.unclutter-xfixes;

in
{
  options.services.unclutter-xfixes = {

    enable = mkOption {
      default = false;
      description = "Enable unclutter-xfixes to hide your mouse cursor when inactive.";
      type = types.bool;
    };

    package = mkPackageOption pkgs "unclutter-xfixes" { };

    extraOptions = mkOption {
      default = [ ];
      description = "More arguments to pass to the unclutter-xfixes command.";

      example = [
        "exclude-root"
        "ignore-scrolling"
        "fork"
      ];

      type = types.listOf types.str;
    };

    threshold = mkOption {
      default = 1;
      description = "Minimum number of pixels considered cursor movement.";
      type = types.int;
    };

    timeout = mkOption {
      default = 1;
      description = "Number of seconds before the cursor is marked inactive.";
      type = types.int;
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.unclutter-xfixes = {
      description = "unclutter-xfixes";
      partOf = [ "graphical-session.target" ];

      serviceConfig.ExecStart = ''
        ${cfg.package}/bin/unclutter \
          --timeout ${toString cfg.timeout} \
          --jitter ${toString (cfg.threshold - 1)} \
          ${concatMapStrings (x: " --" + x) cfg.extraOptions}
      '';

      serviceConfig.Restart = "always";
      serviceConfig.RestartSec = 3;
      wantedBy = [ "graphical-session.target" ];
    };
  };
}
