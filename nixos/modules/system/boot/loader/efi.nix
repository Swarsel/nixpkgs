{ lib, ... }:
{
  options.boot.loader.efi = {

    canTouchEfiVariables = lib.mkOption {
      default = false;
      description = "Whether the installation process is allowed to modify EFI boot variables.";
      type = lib.types.bool;
    };

    efiSysMountPoint = lib.mkOption {
      default = "/boot";
      description = "Where the EFI System Partition is mounted.";
      type = lib.types.str;
    };
  };
}
