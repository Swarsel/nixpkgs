{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    getExe'
    literalExpression
    maintainers
    mkEnableOption
    mkIf
    mkOption
    mkRenamedOptionModule
    optionals
    optionalString
    types
    ;
  cfg = config.virtualisation.vmware.guest;
in
{
  imports = [
    (mkRenamedOptionModule [ "services" "vmwareGuest" ] [ "virtualisation" "vmware" "guest" ])
  ];

  options.virtualisation.vmware.guest = {
    enable = mkEnableOption "VMWare Guest Support";

    package = mkOption {
      default = if cfg.headless then pkgs.open-vm-tools-headless else pkgs.open-vm-tools;
      defaultText = literalExpression "if config.virtualisation.vmware.headless then pkgs.open-vm-tools-headless else pkgs.open-vm-tools;";
      description = "Package providing open-vm-tools.";
      example = literalExpression "pkgs.open-vm-tools";
      type = types.package;
    };

    headless = mkOption {
      default = !config.services.xserver.enable;
      defaultText = literalExpression "!config.services.xserver.enable";
      description = "Whether to disable X11-related features.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.isx86 || pkgs.stdenv.hostPlatform.isAarch64;
        message = "VMWare guest is not currently supported on ${pkgs.stdenv.hostPlatform.system}";
      }
    ];

    boot.initrd.availableKernelModules = [ "mptspi" ];
    boot.initrd.kernelModules = optionals pkgs.stdenv.hostPlatform.isx86 [ "vmw_pvscsi" ];
    environment.etc.vmware-tools.source = "${cfg.package}/etc/vmware-tools/*";
    environment.systemPackages = [ cfg.package ];

    security.wrappers.vmware-user-suid-wrapper = mkIf (!cfg.headless) {
      group = "root";
      owner = "root";
      setuid = true;
      source = getExe' cfg.package "vmware-user-suid-wrapper";
    };

    services.udev.packages = [ cfg.package ];

    services.xserver = mkIf (!cfg.headless) {
      config = optionalString (pkgs.stdenv.hostPlatform.isx86) ''
        Section "InputClass"
          Identifier "VMMouse"
          MatchDevicePath "/dev/input/event*"
          MatchProduct "ImPS/2 Generic Wheel Mouse"
          Driver "vmmouse"
        EndSection
      '';

      displayManager.sessionCommands = ''
        ${getExe' cfg.package "vmware-user-suid-wrapper"}
      '';

      modules = optionals pkgs.stdenv.hostPlatform.isx86 [ pkgs.xf86-input-vmmouse ];
    };

    # Mount the vmblock for drag-and-drop and copy-and-paste.
    systemd.mounts = mkIf (!cfg.headless) [
      {
        options = "subtype=vmware-vmblock,default_permissions,allow_other";
        description = "VMware vmblock fuse mount";

        documentation = [
          "https://github.com/vmware/open-vm-tools/blob/master/open-vm-tools/vmblock-fuse/design.txt"
        ];

        type = "fuse";
        unitConfig.ConditionVirtualization = "vmware";
        wantedBy = [ "multi-user.target" ];
        what = getExe' cfg.package "vmware-vmblock-fuse";
        where = "/run/vmblock-fuse";
      }
    ];

    systemd.services.vmware = {
      after = [ "display-manager.service" ];
      description = "VMWare Guest Service";
      serviceConfig.ExecStart = getExe' cfg.package "vmtoolsd";
      unitConfig.ConditionVirtualization = "vmware";
      wantedBy = [ "multi-user.target" ];
    };
  };

  meta = {
    maintainers = [ maintainers.kjeremy ];
  };
}
