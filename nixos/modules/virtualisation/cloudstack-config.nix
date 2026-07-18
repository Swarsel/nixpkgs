{ lib, pkgs, ... }:

{
  imports = [
    ../profiles/qemu-guest.nix
  ];

  config = {
    boot.growPartition = true;
    boot.kernelParams = [ "console=tty0" ];
    boot.loader.grub.device = "/dev/vda";
    boot.loader.timeout = 0;

    # Only enable CloudStack datasource for faster boot speed.
    environment.etc."cloud/cloud.cfg.d/99_cloudstack.cfg".text = ''
      datasource:
        CloudStack: {}
        None: {}
      datasource_list: ["CloudStack"]
    '';

    # Wget is needed for setting password. This is of little use as
    # root password login is disabled above.
    environment.systemPackages = [ pkgs.wget ];

    fileSystems."/" = lib.mkImageMediaOverride {
      autoResize = true;
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    # Cloud-init configuration.
    services.cloud-init.enable = true;

    # Allow root logins
    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "prohibit-password";
    };
  };
}
