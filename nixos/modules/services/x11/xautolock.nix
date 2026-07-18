{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.xserver.xautolock;
in
{
  options = {
    services.xserver.xautolock = {
      enable = mkEnableOption "xautolock";

      enableNotifier = mkEnableOption "xautolock.notify" // {
        description = ''
          Whether to enable the notifier feature of xautolock.
          This publishes a notification before the autolock.
        '';
      };

      extraOptions = mkOption {
        default = [ ];

        description = ''
          Additional command-line arguments to pass to
          {command}`xautolock`.
        '';

        example = [ "-detectsleep" ];
        type = types.listOf types.str;
      };

      killer = mkOption {
        default = null; # default according to `man xautolock` is none

        description = ''
          The script to use when nothing has happened for as long as {option}`killtime`
        '';

        example = "/run/current-system/systemd/bin/systemctl suspend";
        type = types.nullOr types.str;
      };

      killtime = mkOption {
        default = 20; # default according to `man xautolock`

        description = ''
          Minutes xautolock waits until it executes the script specified in {option}`killer`
          (Has to be at least 10 minutes)
        '';

        type = types.int;
      };

      locker = mkOption {
        default = "${pkgs.xlockmore}/bin/xlock"; # default according to `man xautolock`
        defaultText = literalExpression ''"''${pkgs.xlockmore}/bin/xlock"'';

        description = ''
          The script to use when automatically locking the computer.
        '';

        example = literalExpression ''"''${pkgs.i3lock}/bin/i3lock -i /path/to/img"'';
        type = types.str;
      };

      notifier = mkOption {
        default = null;

        description = ''
          Notification script to be used to warn about the pending autolock.
        '';

        example = literalExpression ''"''${pkgs.libnotify}/bin/notify-send 'Locking in 10 seconds'"'';
        type = types.nullOr types.str;
      };

      notify = mkOption {
        default = 10;

        description = ''
          Time (in seconds) before the actual lock when the notification about the pending lock should be published.
        '';

        type = types.int;
      };

      nowlocker = mkOption {
        default = null;

        description = ''
          The script to use when manually locking the computer with {command}`xautolock -locknow`.
        '';

        example = literalExpression ''"''${pkgs.i3lock}/bin/i3lock -i /path/to/img"'';
        type = types.nullOr types.str;
      };

      time = mkOption {
        default = 15;

        description = ''
          Idle time (in minutes) to wait until xautolock locks the computer.
        '';

        type = types.int;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enableNotifier -> cfg.notifier != null;
        message = "When enabling the notifier for xautolock, you also need to specify the notify script";
      }
      {
        assertion = cfg.killer != null -> cfg.killtime >= 10;
        message = "killtime has to be at least 10 minutes according to `man xautolock`";
      }
    ]
    ++ (lib.forEach [ "locker" "notifier" "nowlocker" "killer" ] (option: {
      assertion = cfg.${option} != null -> builtins.substring 0 1 cfg.${option} == "/";
      message = "Please specify a canonical path for `services.xserver.xautolock.${option}`";
    }));

    environment.systemPackages = with pkgs; [ xautolock ];

    systemd.user.services.xautolock = {
      description = "xautolock service";
      partOf = [ "graphical-session.target" ];

      serviceConfig = with lib; {
        ExecStart = strings.concatStringsSep " " (
          [
            "${pkgs.xautolock}/bin/xautolock"
            "-noclose"
            "-time ${toString cfg.time}"
            "-locker '${cfg.locker}'"
          ]
          ++ optionals cfg.enableNotifier [
            "-notify ${toString cfg.notify}"
            "-notifier '${cfg.notifier}'"
          ]
          ++ optionals (cfg.nowlocker != null) [
            "-nowlocker '${cfg.nowlocker}'"
          ]
          ++ optionals (cfg.killer != null) [
            "-killer '${cfg.killer}'"
            "-killtime ${toString cfg.killtime}"
          ]
          ++ cfg.extraOptions
        );

        Restart = "always";
      };

      wantedBy = [ "graphical-session.target" ];
    };
  };
}
