{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.hardware.cpu.amd;
in
{
  ###### interface
  options = {

    hardware.cpu.amd.microcodePackage = lib.mkPackageOption pkgs "microcode-amd" { };

    hardware.cpu.amd.updateMicrocode = lib.mkOption {
      default = false;

      description = ''
        Update the CPU microcode for AMD processors.
      '';

      type = lib.types.bool;
    };
  };

  ###### implementation
  config = lib.mkIf config.hardware.cpu.amd.updateMicrocode {
    # Microcode updates must be the first item prepended in the initrd
    boot.initrd.prepend = lib.mkOrder 1 [ "${cfg.microcodePackage}/amd-ucode.img" ];
  };

}
