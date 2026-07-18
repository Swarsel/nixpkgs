{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hardware.bumblebee;

  kernel = config.boot.kernelPackages;

  useNvidia = cfg.driver == "nvidia";

  bumblebee = pkgs.bumblebee.override {
    inherit useNvidia;
    useDisplayDevice = cfg.connectDisplay;
  };

  useBbswitch = cfg.pmMethod == "bbswitch" || cfg.pmMethod == "auto" && useNvidia;

  primus = pkgs.primus.override {
    inherit useNvidia;
  };

in

{

  options = {
    hardware.bumblebee = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Enable the bumblebee daemon to manage Optimus hybrid video cards.
          This should power off secondary GPU until its use is requested
          by running an application with optirun.
        '';

        type = lib.types.bool;
      };

      connectDisplay = lib.mkOption {
        default = false;

        description = ''
          Set to true if you intend to connect your discrete card to a
          monitor. This option will set up your Nvidia card for EDID
          discovery and to turn on the monitor signal.

          Only nvidia driver is supported so far.
        '';

        type = lib.types.bool;
      };

      driver = lib.mkOption {
        default = "nvidia";

        description = ''
          Set driver used by bumblebeed. Supported are nouveau and nvidia.
        '';

        type = lib.types.enum [
          "nvidia"
          "nouveau"
        ];
      };

      group = lib.mkOption {
        default = "wheel";
        description = "Group for bumblebee socket";
        example = "video";
        type = lib.types.str;
      };

      pmMethod = lib.mkOption {
        default = "auto";

        description = ''
          Set preferred power management method for unused card.
        '';

        type = lib.types.enum [
          "auto"
          "bbswitch"
          "switcheroo"
          "none"
        ];
      };

    };
  };

  config = lib.mkIf cfg.enable {
    boot.blacklistedKernelModules = [
      "nvidia-drm"
      "nvidia"
      "nouveau"
    ];

    boot.extraModulePackages =
      lib.optional useBbswitch kernel.bbswitch
      ++ lib.optional useNvidia (
        if config.hardware.nvidia.open == true then kernel.nvidia_x11.open else kernel.nvidia_x11.mod
      );

    boot.kernelModules = lib.optional useBbswitch "bbswitch";

    environment.systemPackages = [
      bumblebee
      primus
    ];

    systemd.services.bumblebeed = {
      before = [ "display-manager.service" ];
      description = "Bumblebee Hybrid Graphics Switcher";

      serviceConfig = {
        ExecStart = "${bumblebee}/bin/bumblebeed --use-syslog -g ${cfg.group} --driver ${cfg.driver} --pm-method ${cfg.pmMethod}";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
