{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

with lib;

let
  cfg = config.services.cage;
in
{
  options.services.cage.enable = mkEnableOption "cage kiosk service";

  options.services.cage.environment = mkOption {
    default = { };
    description = "Additional environment variables to pass to Cage.";

    example = {
      WLR_LIBINPUT_NO_DEVICES = "1";
    };

    type = types.attrsOf types.str;
  };

  options.services.cage.extraArguments = mkOption {
    default = [ ];
    defaultText = literalExpression "[]";
    description = "Additional command line arguments to pass to Cage.";
    example = [ "-d" ];
    type = types.listOf types.str;
  };

  options.services.cage.package = mkPackageOption pkgs "cage" { };

  options.services.cage.program = mkOption {
    default = "${pkgs.xterm}/bin/xterm";
    defaultText = literalExpression ''"''${pkgs.xterm}/bin/xterm"'';

    description = ''
      Program to run in cage.
    '';

    type = types.path;
  };

  options.services.cage.user = mkOption {
    default = "demo";

    description = ''
      User to log-in as.
    '';

    type = types.str;
  };

  config = mkIf cfg.enable {

    hardware.graphics.enable = mkDefault true;

    security.pam.services.cage = {
      rules = {
        account = utils.pam.autoOrderRules [
          {
            control = "required";
            modulePath = "${config.security.pam.package}/lib/security/pam_unix.so";
            name = "unix";
          }
        ];

        auth = utils.pam.autoOrderRules [
          {
            control = "required";
            modulePath = "${config.security.pam.package}/lib/security/pam_unix.so";
            name = "unix";
            settings.nullok = true;
          }
        ];

        session = utils.pam.autoOrderRules [
          {
            control = "required";
            modulePath = "${config.security.pam.package}/lib/security/pam_unix.so";
            name = "unix";
          }
          {
            control = "required";
            modulePath = "${config.security.pam.package}/lib/security/pam_env.so";
            name = "env";
            settings.conffile = "/etc/pam/environment";
            settings.readenv = 0;
          }
          {
            control = "required";
            modulePath = "${config.systemd.package}/lib/security/pam_systemd.so";
            name = "systemd";
          }
        ];
      };

      useDefaultRules = false;
    };

    security.polkit.enable = true;
    systemd.defaultUnit = "graphical.target";

    # The service is partially based off of the one provided in the
    # cage wiki at
    # https://github.com/Hjdskes/cage/wiki/Starting-Cage-on-boot-with-systemd.
    systemd.services."cage-tty1" = {
      enable = true;

      after = [
        "systemd-user-sessions.service"
        "plymouth-start.service"
        "plymouth-quit.service"
        "systemd-logind.service"
        "getty@tty1.service"
      ];

      before = [ "graphical.target" ];
      conflicts = [ "getty@tty1.service" ];
      environment = cfg.environment;
      restartIfChanged = false;

      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/cage \
            ${escapeShellArgs cfg.extraArguments} \
            -- ${cfg.program}
        '';

        IgnoreSIGPIPE = "no";
        # Set up a full (custom) user session for the user, required by Cage.
        PAMName = "cage";
        StandardError = "journal";
        # Fail to start if not controlling the virtual terminal.
        StandardInput = "tty-fail";
        StandardOutput = "journal";
        # A virtual terminal is needed.
        TTYPath = "/dev/tty1";
        TTYReset = "yes";
        TTYVHangup = "yes";
        TTYVTDisallocate = "yes";
        User = cfg.user;
        # Log this user with utmp, letting it show up with commands 'w' and
        # 'who'. This is needed since we replace (a)getty.
        UtmpIdentifier = "%n";
        UtmpMode = "user";
      };

      unitConfig.ConditionPathExists = "/dev/tty1";
      wantedBy = [ "graphical.target" ];

      wants = [
        "dbus.socket"
        "systemd-logind.service"
        "plymouth-quit.service"
      ];
    };

    systemd.targets.graphical.wants = [ "cage-tty1.service" ];
  };

  meta.maintainers = [ ];

}
