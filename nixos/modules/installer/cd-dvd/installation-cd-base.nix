# This module contains the basic configuration for building a NixOS
# installation CD.
{
  config,
  lib,
  pkgs,
  options,
  ...
}:
{
  imports = [
    ./iso-image.nix

    # Profiles of this basic installation CD.
    ../../profiles/base.nix
    ../../profiles/installation-device.nix
  ];

  boot.initrd.luks.devices = lib.mkImageMediaOverride { };
  # Add Memtest86+ to the CD.
  boot.loader.grub.memtest86.enable = true;

  boot.postBootCommands = ''
    for o in $(</proc/cmdline); do
      case "$o" in
        live.nixos.passwd=*)
          set -- $(IFS==; echo $o)
          echo "nixos:$2" | ${pkgs.shadow}/bin/chpasswd
          ;;
      esac
    done
  '';

  # Adds terminus_font for people with HiDPI displays
  console.packages = options.console.packages.default ++ [ pkgs.terminus_font ];

  environment.defaultPackages = with pkgs; [
    rsync
  ];

  fileSystems = lib.mkImageMediaOverride config.lib.isoFileSystems;
  hardware.enableAllHardware = true;
  # EFI booting
  isoImage.makeEfiBootable = true;
  # USB booting
  isoImage.makeUsbBootable = true;
  programs.git.enable = lib.mkDefault true;
  # An installation media cannot tolerate a host config defined file
  # system layout on a fresh machine, before it has been formatted.
  swapDevices = lib.mkImageMediaOverride [ ];
  system.stateVersion = lib.mkDefault lib.trivial.release;
}
