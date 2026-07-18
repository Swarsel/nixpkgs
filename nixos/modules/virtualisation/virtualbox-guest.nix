# Module for VirtualBox guests.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.virtualisation.virtualbox.guest;
  kernel = config.boot.kernelPackages;

  mkVirtualBoxUserService = serviceArgs: verbose: {
    description = "VirtualBox Guest User Services ${serviceArgs}";
    partOf = [ "graphical-session.target" ];
    # Check if the display environment is ready, otherwise fail
    preStart = "${pkgs.bash}/bin/bash -c \"if [ -z $DISPLAY ]; then exit 1; fi\"";

    serviceConfig = {
      ExecStart =
        "@${kernel.virtualboxGuestAdditions}/bin/VBoxClient"
        + (lib.strings.optionalString verbose " --verbose")
        + " --foreground ${serviceArgs}";

      Restart = "always";
      # Wait after a failure, hoping that the display environment is ready after waiting
      RestartSec = 2;
    };

    # The graphical session may not be ready when starting the service
    # Hence, check if the DISPLAY env var is set, otherwise fail, wait and retry again
    startLimitBurst = 20;
    unitConfig.ConditionVirtualization = "oracle";
    wantedBy = [ "graphical-session.target" ];
  };

  mkVirtualBoxUserX11OnlyService =
    serviceArgs: verbose:
    (mkVirtualBoxUserService serviceArgs verbose)
    // {
      unitConfig.ConditionEnvironment = "XDG_SESSION_TYPE=x11";
    };
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [
        "virtualisation"
        "virtualbox"
        "guest"
        "draganddrop"
      ]
      [
        "virtualisation"
        "virtualbox"
        "guest"
        "dragAndDrop"
      ]
    )
  ];

  options.virtualisation.virtualbox.guest = {
    enable = lib.mkOption {
      default = false;
      description = "Whether to enable the VirtualBox service and other guest additions.";
      type = lib.types.bool;
    };

    clipboard = lib.mkOption {
      default = true;
      description = "Whether to enable clipboard support.";
      type = lib.types.bool;
    };

    dragAndDrop = lib.mkOption {
      default = true;
      description = "Whether to enable drag and drop support.";
      type = lib.types.bool;
    };

    seamless = lib.mkOption {
      default = true;
      description = "Whether to enable seamless mode. When activated windows from the guest appear next to the windows of the host.";
      type = lib.types.bool;
    };

    use3rdPartyModules = lib.mkOption {
      default = true;
      description = "Whether to use the kernel modules provided by VirtualBox instead of the ones from the upstream kernel.";
      type = lib.types.bool;
    };

    vboxsf = lib.mkOption {
      default = true;
      description = "Whether to load vboxsf";
      type = lib.types.bool;
    };

    verbose = lib.mkOption {
      default = false;
      description = "Whether to verbose logging for guest services.";
      type = lib.types.bool;
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = pkgs.stdenv.hostPlatform.isx86 || pkgs.stdenv.hostPlatform.isAarch64;
            message = "Virtualbox not currently supported on ${pkgs.stdenv.hostPlatform.system}";
          }
        ];

        boot.extraModulePackages = lib.mkIf cfg.use3rdPartyModules [ kernel.virtualboxGuestAdditions ];
        environment.systemPackages = [ kernel.virtualboxGuestAdditions ];

        services.udev.extraRules = ''
          # /dev/vboxuser is necessary for VBoxClient to work.  Maybe we
          # should restrict this to logged-in users.
          KERNEL=="vboxuser",  OWNER="root", GROUP="vboxuserdev", MODE="0660", TAG+="uaccess"

          # Allow systemd dependencies on vboxguest.
          SUBSYSTEM=="misc", KERNEL=="vboxguest", TAG+="systemd"
        '';

        systemd.services.virtualbox = {
          after = [ "dev-vboxguest.device" ];
          description = "VirtualBox Guest Services";
          requires = [ "dev-vboxguest.device" ];
          serviceConfig.ExecStart = "@${kernel.virtualboxGuestAdditions}/bin/VBoxService VBoxService --foreground";
          unitConfig.ConditionVirtualization = "oracle";
          wantedBy = [ "multi-user.target" ];
        };

        systemd.user.services.virtualboxClientVmsvga = mkVirtualBoxUserService "--vmsvga-session" cfg.verbose;
        users.groups.vboxuserdev = { };
      }
      (lib.mkIf cfg.vboxsf {
        boot.initrd.supportedFilesystems = [ "vboxsf" ];
        boot.supportedFilesystems = [ "vboxsf" ];
        users.groups.vboxsf.gid = config.ids.gids.vboxsf;
      })
      (lib.mkIf cfg.clipboard {
        systemd.user.services.virtualboxClientClipboard = mkVirtualBoxUserService "--clipboard" cfg.verbose;
      })
      (lib.mkIf cfg.seamless {
        systemd.user.services.virtualboxClientSeamless = mkVirtualBoxUserX11OnlyService "--seamless" cfg.verbose;
      })
      (lib.mkIf cfg.dragAndDrop {
        systemd.user.services.virtualboxClientDragAndDrop = mkVirtualBoxUserService "--draganddrop" cfg.verbose;
      })
    ]
  );
}
