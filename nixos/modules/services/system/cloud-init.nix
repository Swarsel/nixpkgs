{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.cloud-init;
  path =
    with pkgs;
    [
      cloud-init
      iproute2
      net-tools
      openssh
      shadow
      util-linux
      busybox
    ]
    ++ lib.optional cfg.btrfs.enable btrfs-progs
    ++ lib.optional cfg.ext4.enable e2fsprogs
    ++ lib.optional cfg.xfs.enable xfsprogs
    ++ cfg.extraPackages;
  hasFs = fsName: lib.any (fs: fs.fsType == fsName) (lib.attrValues config.fileSystems);
  settingsFormat = pkgs.formats.yaml { };
  cfgfile = settingsFormat.generate "cloud.cfg" cfg.settings;
in
{
  options = {
    services.cloud-init = {
      config = lib.mkOption {
        default = "";

        description = ''
          raw cloud-init configuration.

          Takes precedence over the `settings` option if set.
        '';

        type = lib.types.str;
      };

      enable = lib.mkOption {
        default = false;

        description = ''
          Enable the cloud-init service. This services reads
          configuration metadata in a cloud environment and configures
          the machine according to this metadata.

          This configuration is not completely compatible with the
          NixOS way of doing configuration, as configuration done by
          cloud-init might be overridden by a subsequent nixos-rebuild
          call. However, some parts of cloud-init fall outside of
          NixOS's responsibility, like filesystem resizing and ssh
          public key provisioning, and cloud-init is useful for that
          parts. Thus, be wary that using cloud-init in NixOS might
          come as some cost.
        '';

        type = lib.types.bool;
      };

      btrfs.enable = lib.mkOption {
        default = hasFs "btrfs";
        defaultText = lib.literalExpression ''hasFs "btrfs"'';

        description = ''
          Allow the cloud-init service to operate `btrfs` filesystem.
        '';

        type = lib.types.bool;
      };

      ext4.enable = lib.mkOption {
        default = hasFs "ext4";
        defaultText = lib.literalExpression ''hasFs "ext4"'';

        description = ''
          Allow the cloud-init service to operate `ext4` filesystem.
        '';

        type = lib.types.bool;
      };

      extraPackages = lib.mkOption {
        default = [ ];

        description = ''
          List of additional packages to be available within cloud-init jobs.
        '';

        type = lib.types.listOf lib.types.package;
      };

      network.enable = lib.mkOption {
        default = false;

        description = ''
          Allow the cloud-init service to configure network interfaces
          through systemd-networkd.
        '';

        type = lib.types.bool;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Structured cloud-init configuration.
        '';

        type = lib.types.submodule {
          freeformType = settingsFormat.type;
        };
      };

      xfs.enable = lib.mkOption {
        default = hasFs "xfs";
        defaultText = lib.literalExpression ''hasFs "xfs"'';

        description = ''
          Allow the cloud-init service to operate `xfs` filesystem.
        '';

        type = lib.types.bool;
      };

    };

  };

  config = lib.mkIf cfg.enable {
    environment.etc."cloud/cloud.cfg" =
      if cfg.config == "" then { source = cfgfile; } else { text = cfg.config; };

    services.cloud-init.settings = {
      cloud_config_modules = lib.mkDefault [
        "disk_setup"
        "mounts"
        "ssh-import-id"
        "set-passwords"
        "timezone"
        "disable-ec2-metadata"
        "runcmd"
        "ssh"
      ];

      cloud_final_modules = lib.mkDefault [
        "rightscale_userdata"
        "scripts-vendor"
        "scripts-per-once"
        "scripts-per-boot"
        "scripts-per-instance"
        "scripts-user"
        "ssh-authkey-fingerprints"
        "keys-to-console"
        "phone-home"
        "final-message"
        "power-state-change"
      ];

      cloud_init_modules = lib.mkDefault [
        "migrator"
        "seed_random"
        "bootcmd"
        "write-files"
        "growpart"
        "resizefs"
        "update_hostname"
        "resolv_conf"
        "ca-certs"
        "rsyslog"
        "users-groups"
      ];

      disable_root = lib.mkDefault false;
      preserve_hostname = lib.mkDefault false;

      system_info = lib.mkDefault {
        distro = "nixos";

        network = {
          renderers = [ "networkd" ];
        };
      };

      users = lib.mkDefault [ "root" ];
    };

    systemd.network.enable = lib.mkIf cfg.network.enable true;

    systemd.services.cloud-config = {
      after = [
        "network-online.target"
        "cloud-config.target"
      ];

      description = "Apply the settings specified in cloud-config";
      path = path;

      serviceConfig = {
        ExecStart = "${pkgs.cloud-init}/bin/cloud-init modules --mode=config";
        RemainAfterExit = "yes";
        StandardOutput = "journal+console";
        TimeoutSec = "infinity";
        Type = "oneshot";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    systemd.services.cloud-final = {
      after = [
        "network-online.target"
        "cloud-config.service"
        "rc-local.service"
      ];

      description = "Execute cloud user/final scripts";
      path = path;
      requires = [ "cloud-config.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.cloud-init}/bin/cloud-init modules --mode=final";
        RemainAfterExit = "yes";
        StandardOutput = "journal+console";
        TimeoutSec = "infinity";
        Type = "oneshot";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    systemd.services.cloud-init = {
      after = [
        "network-online.target"
        "cloud-init-local.service"
      ];

      before = [
        "sshd.service"
        "sshd-keygen.service"
      ];

      description = "Initial cloud-init job (metadata service crawler)";
      path = path;
      requires = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.cloud-init}/bin/cloud-init init";
        RemainAfterExit = "yes";
        StandardOutput = "journal+console";
        TimeoutSec = "infinity";
        Type = "oneshot";
      };

      wantedBy = [ "multi-user.target" ];

      wants = [
        "network-online.target"
        "cloud-init-local.service"
        "sshd.service"
        "sshd-keygen.service"
      ];
    };

    systemd.services.cloud-init-local = {
      # In certain environments (AWS for example), cloud-init-local will
      # first configure an IP through DHCP, and later delete it.
      # This can cause race conditions with anything else trying to set IP through DHCP.
      before = [
        "systemd-networkd.service"
        "dhcpcd.service"
      ];

      description = "Initial cloud-init job (pre-networking)";
      path = path;

      serviceConfig = {
        ExecStart = "${pkgs.cloud-init}/bin/cloud-init init --local";
        RemainAfterExit = "yes";
        StandardOutput = "journal+console";
        TimeoutSec = "infinity";
        Type = "oneshot";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.targets.cloud-config = {
      description = "Cloud-config availability";

      requires = [
        "cloud-init-local.service"
        "cloud-init.service"
      ];
    };
  };

  meta.maintainers = [ lib.maintainers.zimbatm ];
}
