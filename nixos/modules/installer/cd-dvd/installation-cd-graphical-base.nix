# This module contains the basic configuration for building a graphical NixOS
# installation CD.
{ lib, pkgs, ... }:
{
  imports = [ ./installation-cd-base.nix ];
  # Enable plymouth
  boot.plymouth.enable = true;

  environment.defaultPackages = with pkgs; [
    # Include gparted for partitioning disks.
    gparted

    # Include some editors.
    vim
    nano

    # Firefox for reading the manual.
    firefox

    mesa-demos
  ];

  # KDE complains if power management is disabled (to be precise, if
  # there is no power management backend such as upower).
  powerManagement.enable = true;

  # Whitelist wheel users to do anything
  # This is useful for things like pkexec
  #
  # WARNING: this is dangerous for systems
  # outside the installation-cd and shouldn't
  # be used anywhere else.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  services.qemuGuest.enable = true;
  # VM guest additions to improve host-guest interaction
  services.spice-vdagentd.enable = true;
  services.xe-guest-utilities.enable = pkgs.stdenv.hostPlatform.isx86;
  services.xserver.enable = true;

  # https://github.com/torvalds/linux/blob/00b827f0cffa50abb6773ad4c34f4cd909dae1c8/drivers/hv/Kconfig#L7-L8
  virtualisation.hypervGuest.enable =
    pkgs.stdenv.hostPlatform.isx86 || pkgs.stdenv.hostPlatform.isAarch64;

  # The VirtualBox guest additions rely on an out-of-tree kernel module
  # which lags behind kernel releases, potentially causing broken builds.
  virtualisation.virtualbox.guest.enable = false;
  virtualisation.vmware.guest.enable = pkgs.stdenv.hostPlatform.isx86;

}
