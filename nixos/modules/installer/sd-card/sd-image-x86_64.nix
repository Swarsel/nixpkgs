# To build, use:
# nix-build nixos -I nixos-config=nixos/modules/installer/sd-card/sd-image-x86_64.nix -A config.system.build.sdImage

# This image is primarily used in NixOS tests (boot.nix) to test `boot.loader.generic-extlinux-compatible`.
{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../../profiles/base.nix
    ./sd-image.nix
  ];

  boot.consoleLogLevel = lib.mkDefault 7;

  boot.loader = {
    generic-extlinux-compatible.enable = true;
    grub.enable = false;
  };

  sdImage = {
    populateFirmwareCommands = "";

    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };
}
