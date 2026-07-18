{ config, lib, ... }:
let
  cfg = config.services.displayManager.generic;
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "displayManager" "preStart" ]
      [ "services" "displayManager" "generic" "preStart" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "displayManager" "execCmd" ]
      [ "services" "displayManager" "generic" "execCmd" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "displayManager" "environment" ]
      [ "services" "displayManager" "generic" "environment" ]
    )
  ];

  options = {
    services.displayManager.generic = {
      enable = lib.mkEnableOption "generic display manager integration - deprecated";

      environment = lib.mkOption {
        default = { };
        description = "Additional environment variables needed by the display manager.";
        type = with lib.types; attrsOf unspecified;
      };

      execCmd = lib.mkOption {
        default = null;
        description = "Command to start the display manager.";
        example = lib.literalExpression ''"''${pkgs.lightdm}/bin/lightdm"'';
        type = lib.types.nullOr lib.types.str;
      };

      preStart = lib.mkOption {
        default = "";
        description = "Script executed before the display manager is started.";
        example = "rm -f /var/log/my-display-manager.log";
        type = lib.types.lines;
      };
    };
  };

  config = lib.mkIf (cfg.enable || cfg.execCmd != null) {
    services.displayManager.enable = true;

    systemd.services.display-manager = {
      after = [
        "acpid.service"
        "systemd-logind.service"
        "systemd-user-sessions.service"
        "autovt@tty1.service"
      ];

      conflicts = [
        "autovt@tty1.service"
      ];

      description = "Display Manager";
      environment = cfg.environment;
      preStart = cfg.preStart;
      restartIfChanged = false;
      script = cfg.execCmd;

      serviceConfig = {
        Restart = "always";
        RestartSec = "200ms";
        SyslogIdentifier = "display-manager";
      };

      startLimitBurst = 3;
      # Stop restarting if the display manager stops (crashes) 2 times
      # in one minute. Starting X typically takes 3-4s.
      startLimitIntervalSec = 30;
    };

    warnings = [
      (lib.mkIf (!cfg.enable) ''
        Enabling display-manager.service implicitly due to `services.displayManager.generic.execCmd` being set; this will be removed eventually.
        Please set `services.displayManager.generic.enable` explicitly, or switch your display manager to use upstream systemd units (preferred).
      '')
    ];
  };
}
