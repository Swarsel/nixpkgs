{ config, lib, ... }:
let

  cfg = config.powerManagement;

in

{

  ###### interface

  options = {

    powerManagement = {

      enable = lib.mkOption {
        default = true;

        description = ''
          Whether to enable power management.  This includes support
          for suspend-to-RAM and powersave features on laptops.
        '';

        type = lib.types.bool;
      };

      bootCommands = lib.mkOption {
        default = "";

        description = ''
          Commands executed only once after initial boot.
          These commands are executed before `powerUpCommands`.
        '';

        example = lib.literalExpression ''
          "''${pkgs.networkmanager}/bin/nmcli radio wifi on"
        '';

        type = lib.types.lines;
      };

      powerDownCommands = lib.mkOption {
        default = "";

        description = ''
          Commands executed when the machine powers down.  That is,
          they're executed both when the system shuts down and when
          it goes to suspend or hibernation.
        '';

        example = lib.literalExpression ''
          "''${pkgs.hdparm}/sbin/hdparm -B 255 /dev/sda"
        '';

        type = lib.types.lines;
      };

      powerUpCommands = lib.mkOption {
        default = "";

        description = ''
          Commands executed when the machine powers up.  That is,
          they're executed both when the system first boots and when
          it resumes from suspend or hibernation.
        '';

        example = lib.literalExpression ''
          "''${pkgs.powertop}/bin/powertop --auto-tune"
        '';

        type = lib.types.lines;
      };

      resumeCommands = lib.mkOption {
        default = "";
        description = "Commands executed after the system resumes from suspend-to-RAM.";

        example = lib.literalExpression ''
          "''${pkgs.util-linux}/bin/rfkill unblock all"
        '';

        type = lib.types.lines;
      };

    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    systemd.services = {
      # Service executed after boot, and stopped during shutdown
      post-boot = {
        description = "Post-Boot Actions";

        preStop = ''
          # NixOS pre-shutdown script

          # config.powerManagement.powerDownCommands
          ${cfg.powerDownCommands}
        '';

        restartIfChanged = false;

        script = ''
          # NixOS post-boot script

          # config.powerManagement.bootCommands
          ${cfg.bootCommands}

          # config.powerManagement.powerUpCommands
          ${cfg.powerUpCommands}
        '';

        serviceConfig = {
          RemainAfterExit = true;
          Type = "oneshot";
        };

        # It's not well defined at what point in the bootup sequence this should run
        # we should eventually just remove this.
        wantedBy = [ "multi-user.target" ];
      };

      # Service executed before suspending/hibernating.
      sleep-actions = {
        before = [ "sleep.target" ];
        description = "Sleep Actions";

        preStop = ''
          # NixOS pre-resume script

          # config.powerManagement.resumeCommands
          ${cfg.resumeCommands}

          # config.powerManagement.powerUpCommands
          ${cfg.powerUpCommands}
        '';

        script = ''
          # NixOS pre-sleep script

          # config.powerManagement.powerDownCommands
          ${cfg.powerDownCommands}
        '';

        serviceConfig = {
          RemainAfterExit = true;
          Type = "oneshot";
        };

        unitConfig.StopWhenUnneeded = true;
        wantedBy = [ "sleep.target" ];
      };
    };

    warnings = lib.optional (cfg.powerUpCommands != "") ''
      powerManagement.powerUpCommands is deprecated due to it having unclear ordering semantics.
      It will be removed in NixOS 26.11.
      It is recommended to create an explicit systemd oneshot service instead,
      that is pulled in at the right time during the boot process.
      See https://www.freedesktop.org/software/systemd/man/latest/systemd.special.html
      for more information on possible targets that can be used for this.

      If you also want to run this service upon waking up from resume, the recommended
      method to do so is described here:
      https://www.freedesktop.org/software/systemd/man/latest/systemd.special.html#sleep.target
    '';

  };

}
