{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    boolToString
    mkDefault
    mkIf
    optional
    ;
in

{
  imports = [
    ../profiles/headless.nix
    ../profiles/qemu-guest.nix
  ];

  boot.growPartition = true;
  boot.initrd.kernelModules = [ "virtio_scsi" ];

  boot.kernelModules = [
    "virtio_pci"
    "virtio_net"
  ];

  boot.kernelParams = [
    "console=ttyS0"
    "panic=1"
    "boot.panic_on_fail"
  ];

  # Don't put old configurations in the GRUB menu.  The user has no
  # way to select them anyway.
  boot.loader.grub.configurationLimit = 0;
  # Generate a GRUB menu.
  boot.loader.grub.device = "/dev/sda";
  boot.loader.timeout = 0;

  environment.etc."default/instance_configs.cfg".text = ''
    [Accounts]
    useradd_cmd = useradd -m -s /run/current-system/sw/bin/bash -p * {user}

    [Daemons]
    accounts_daemon = ${boolToString config.users.mutableUsers}

    [InstanceSetup]
    # Make sure GCE image does not replace host key that NixOps sets.
    set_host_keys = false

    [MetadataScripts]
    default_shell = ${pkgs.stdenv.shell}

    [NetworkInterfaces]
    dhclient_script = ${pkgs.google-guest-configs}/bin/google-dhclient-script
    # We set up network interfaces declaratively.
    setup = false
  '';

  environment.etc."modprobe.d/gce-blacklist.conf".source =
    "${pkgs.google-guest-configs}/etc/modprobe.d/gce-blacklist.conf";

  environment.etc."sysctl.d/60-gce-network-security.conf".source =
    "${pkgs.google-guest-configs}/etc/sysctl.d/60-gce-network-security.conf";

  # Always include cryptsetup so that NixOps can use it.
  environment.systemPackages = [ pkgs.cryptsetup ];

  fileSystems."/" = {
    autoResize = true;
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # Configure default metadata hostnames
  networking.extraHosts = ''
    169.254.169.254 metadata.google.internal metadata
  '';

  # Rely on GCP's firewall instead
  networking.firewall.enable = mkDefault false;
  # Force getting the hostname from Google Compute.
  networking.hostName = mkDefault "";
  # GC has 1460 MTU
  networking.interfaces.eth0.mtu = 1460;
  networking.timeServers = [ "metadata.google.internal" ];
  networking.usePredictableInterfaceNames = false;
  # enable OS Login. This also requires setting enable-oslogin=TRUE metadata on
  # instance or project level
  security.googleOsLogin.enable = true;

  security.sudo.extraRules = mkIf config.users.mutableUsers [
    {
      commands = [
        {
          options = [ "NOPASSWD" ];
          command = "ALL";
        }
      ];

      groups = [ "google-sudoers" ];
    }
  ];

  security.sudo-rs.extraRules = mkIf config.users.mutableUsers [
    {
      commands = [
        {
          options = [ "NOPASSWD" ];
          command = "ALL";
        }
      ];

      groups = [ "google-sudoers" ];
    }
  ];

  # Allow root logins only using SSH keys
  # and disable password authentication in general
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = mkDefault false;
  services.openssh.settings.PermitRootLogin = mkDefault "prohibit-password";
  # Use GCE udev rules for dynamic disk volumes
  services.udev.packages = [ pkgs.google-guest-configs ];
  services.udev.path = [ pkgs.google-guest-configs ];
  systemd.packages = [ pkgs.google-guest-agent ];

  systemd.services.google-guest-agent = {
    path = optional config.users.mutableUsers pkgs.shadow;
    restartTriggers = [ config.environment.etc."default/instance_configs.cfg".source ];
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.google-shutdown-scripts.wantedBy = [ "multi-user.target" ];
  systemd.services.google-startup-scripts.wantedBy = [ "multi-user.target" ];
  users.groups.google-sudoers = mkIf config.users.mutableUsers { };
}
