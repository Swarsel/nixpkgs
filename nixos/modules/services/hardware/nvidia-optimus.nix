{ config, lib, ... }:

let
  kernel = config.boot.kernelPackages;
in

{

  ###### interface

  options = {

    hardware.nvidiaOptimus.disable = lib.mkOption {
      default = false;

      description = ''
        Completely disable the NVIDIA graphics card and use the
        integrated graphics processor instead.
      '';

      type = lib.types.bool;
    };

  };

  ###### implementation

  config = lib.mkIf config.hardware.nvidiaOptimus.disable {
    boot.blacklistedKernelModules = [
      "nouveau"
      "nvidia"
      "nvidiafb"
      "nvidia-drm"
      "nvidia-uvm"
      "nvidia-modeset"
    ];

    boot.extraModulePackages = [ kernel.bbswitch ];
    boot.kernelModules = [ "bbswitch" ];

    systemd.services.bbswitch = {
      description = "Disable NVIDIA Card";
      path = [ kernel.bbswitch ];

      serviceConfig = {
        ExecStart = "${kernel.bbswitch}/bin/discrete_vga_poweroff";
        ExecStop = "${kernel.bbswitch}/bin/discrete_vga_poweron";
        RemainAfterExit = true;
        Type = "oneshot";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

}
