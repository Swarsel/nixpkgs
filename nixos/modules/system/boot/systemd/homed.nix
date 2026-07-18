{
  config,
  lib,
  utils,
  ...
}:

let
  cfg = config.services.homed;
in

{
  options.services.homed = {
    enable = lib.mkEnableOption "systemd home area/user account manager";

    promptOnFirstBoot =
      lib.mkEnableOption ''
        interactively prompting for user creation on first boot
      ''
      // {
        default = true;
      };

    settings.Home = lib.mkOption {
      default = { };

      description = ''
        Options for systemd-homed. See {manpage}`homed.conf(5)` man page for
        available options.
      '';

      example = {
        DefaultFileSystemType = "btrfs";
        DefaultStorage = "luks";
      };

      type = lib.types.submodule {
        freeformType = lib.types.attrsOf utils.systemdUtils.unitOptions.unitOption;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.nscd.enable;

        message = ''
          systemd-homed requires the use of the systemd nss module.
          services.nscd.enable must be set to true.
        '';
      }
    ];

    # Enable creation and mounting of LUKS home areas with all filesystems
    # supported by systemd-homed.
    boot.supportedFilesystems = [
      "btrfs"
      "ext4"
      "xfs"
    ];

    environment.etc."systemd/homed.conf".text = ''
      [Home]
      ${utils.systemdUtils.lib.attrsToSection cfg.settings.Home}
    '';

    # homed exposes SSH public keys and other user metadata using userdb
    services.userdbd = {
      enable = true;
      enableSSHSupport = lib.mkDefault config.services.openssh.enable;
    };

    systemd.additionalUpstreamSystemUnits = [
      "systemd-homed.service"
      "systemd-homed-activate.service"
      "systemd-homed-firstboot.service"
    ];

    systemd.services = {
      systemd-homed = {
        aliases = [ "dbus-org.freedesktop.home1.service" ];
        # These packages are required to manage home areas with LUKS storage
        path = config.system.fsPackages;
        wantedBy = [ "multi-user.target" ];
      };

      systemd-homed-activate = {
        wantedBy = [ "systemd-homed.service" ];
      };

      systemd-homed-firstboot = {
        enable = cfg.promptOnFirstBoot;
        wantedBy = [ "systemd-homed.service" ];
      };
    };
  };
}
