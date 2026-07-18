{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.unclutter;

in
{
  imports = [
    (mkRenamedOptionModule
      [ "services" "unclutter" "threeshold" ]
      [ "services" "unclutter" "threshold" ]
    )
  ];

  options.services.unclutter = {

    enable = mkOption {
      default = false;
      description = "Enable unclutter to hide your mouse cursor when inactive";
      type = types.bool;
    };

    package = mkPackageOption pkgs "unclutter" { };

    excluded = mkOption {
      default = [ ];
      description = "Names of windows where unclutter should not apply";
      example = [ "" ];
      type = types.listOf types.str;
    };

    extraOptions = mkOption {
      default = [ ];
      description = "More arguments to pass to the unclutter command";

      example = [
        "noevent"
        "grab"
      ];

      type = types.listOf types.str;
    };

    keystroke = mkOption {
      default = false;
      description = "Wait for a keystroke before hiding the cursor";
      type = types.bool;
    };

    threshold = mkOption {
      default = 1;
      description = "Minimum number of pixels considered cursor movement";
      type = types.int;
    };

    timeout = mkOption {
      default = 1;
      description = "Number of seconds before the cursor is marked inactive";
      type = types.int;
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.unclutter = {
      description = "unclutter";
      partOf = [ "graphical-session.target" ];

      serviceConfig.ExecStart = ''
        ${cfg.package}/bin/unclutter \
          -idle ${toString cfg.timeout} \
          -jitter ${toString (cfg.threshold - 1)} \
          ${optionalString cfg.keystroke "-keystroke"} \
          ${concatMapStrings (x: " -" + x) cfg.extraOptions} \
          -not ${concatStringsSep " " cfg.excluded}
      '';

      serviceConfig.PassEnvironment = "DISPLAY";
      serviceConfig.Restart = "always";
      serviceConfig.RestartSec = 3;
      wantedBy = [ "graphical-session.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ rnhmjoj ];

}
