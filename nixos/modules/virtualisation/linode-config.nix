{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  imports = [ ../profiles/qemu-guest.nix ];

  # Enable LISH and Linode Booting w/ GRUB
  boot = {
    # Add Required Kernel Modules
    # NOTE: These are not documented in the install guide
    initrd.availableKernelModules = [
      "virtio_pci"
      "virtio_scsi"
      "ahci"
      "sd_mod"
    ];

    kernelModules = [ "virtio_net" ];
    # Set Up LISH Serial Connection
    kernelParams = [ "console=ttyS0,19200n8" ];

    loader = {
      grub = {
        enable = true;
        device = "nodev";

        # Allow serial connection for GRUB to be able to use LISH
        extraConfig = ''
          serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
          terminal_input serial;
          terminal_output serial
        '';

        forceInstall = true;
      };

      # Increase Timeout to Allow LISH Connection
      # NOTE: The image generator tries to set a timeout of 0, so we must force
      timeout = lib.mkForce 10;
    };
  };

  # Install diagnostic tools for Linode support
  environment.systemPackages = with pkgs; [
    inetutils
    mtr
    sysstat
  ];

  fileSystems."/" = {
    autoResize = true;
    device = "/dev/sda";
    fsType = "ext4";
  };

  networking = {
    interfaces.eth0 = {
      # Linode expects IPv6 privacy extensions to be disabled, so disable them
      # See: https://www.linode.com/docs/guides/manual-network-configuration/#static-vs-dynamic-addressing
      tempAddress = "disabled";
      useDHCP = true;
    };

    useDHCP = false;
    usePredictableInterfaceNames = false;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = mkDefault false;
    settings.PermitRootLogin = "prohibit-password";
  };

  swapDevices = mkDefault [ { device = "/dev/sdb"; } ];
}
