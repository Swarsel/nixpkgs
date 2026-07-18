{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
with lib;
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/virtualisation/digital-ocean-init.nix")
  ];

  options.virtualisation.digitalOcean = with types; {
    seedEntropy = mkOption {
      default = true;
      description = "Whether to run the kernel RNG entropy seeding script from the Digital Ocean vendor data";
      example = true;
      type = bool;
    };

    setRootPassword = mkOption {
      default = false;
      description = "Whether to set the root password from the Digital Ocean metadata";
      example = true;
      type = bool;
    };

    setSshKeys = mkOption {
      default = true;
      description = "Whether to fetch ssh keys from Digital Ocean";
      example = true;
      type = bool;
    };
  };

  config =
    let
      cfg = config.virtualisation.digitalOcean;
      hostName = config.networking.hostName;
      doMetadataFile = "/run/do-metadata/v1.json";
    in
    mkMerge [
      {
        boot = {
          growPartition = true;
          initrd.kernelModules = [ "virtio_scsi" ];

          kernelModules = [
            "virtio_pci"
            "virtio_net"
          ];

          kernelParams = [
            "console=ttyS0"
            "panic=1"
            "boot.panic_on_fail"
          ];

          loader.grub.devices = [ "/dev/vda" ];
        };

        fileSystems."/" = lib.mkDefault {
          autoResize = true;
          device = "/dev/disk/by-label/nixos";
          fsType = "ext4";
        };

        networking = {
          hostName = mkDefault ""; # use Digital Ocean metadata server
        };

        services.do-agent.enable = mkDefault true;

        services.openssh = {
          enable = mkDefault true;
          settings.PasswordAuthentication = mkDefault false;
        };

        /*
          Initialize the RNG by running the entropy-seed script from the
          Digital Ocean metadata
        */
        systemd.services.digitalocean-entropy-seed = mkIf cfg.seedEntropy {
          description = "Run the kernel RNG entropy seeding script from the Digital Ocean vendor data";

          path = [
            pkgs.jq
            pkgs.mpack
          ];

          script = ''
            set -eo pipefail
            TEMPDIR=$(mktemp -d)
            jq -er '.vendor_data' ${doMetadataFile} | munpack -tC $TEMPDIR
            ENTROPY_SEED=$(grep -rl "DigitalOcean Entropy Seed script" $TEMPDIR)
            ${pkgs.runtimeShell} $ENTROPY_SEED
            rm -rf $TEMPDIR
          '';

          serviceConfig = {
            Type = "oneshot";
          };

          unitConfig = {
            After = [ "digitalocean-metadata.service" ];
            Before = [ "network.target" ];
            Requires = [ "digitalocean-metadata.service" ];
          };

          wantedBy = [ "network.target" ];
        };

        /*
          Check for and wait for the metadata server to become reachable.
          This serves as a dependency for all the other metadata services.
        */
        systemd.services.digitalocean-metadata = {
          description = "Get host metadata provided by Digitalocean";

          environment = {
            DO_DELAY_ATTEMPTS_MAX = "10";
          };

          path = [ pkgs.curl ];

          script = ''
            set -eu
            DO_DELAY_ATTEMPTS=0
            while ! curl -fsSL -o $RUNTIME_DIRECTORY/v1.json http://169.254.169.254/metadata/v1.json; do
              DO_DELAY_ATTEMPTS=$((DO_DELAY_ATTEMPTS + 1))
              if (( $DO_DELAY_ATTEMPTS >= $DO_DELAY_ATTEMPTS_MAX )); then
                echo "giving up"
                exit 1
              fi

              echo "metadata unavailable, trying again in 1s..."
              sleep 1
            done
            chmod 600 $RUNTIME_DIRECTORY/v1.json
          '';

          serviceConfig = {
            RemainAfterExit = true;
            RuntimeDirectory = "do-metadata";
            RuntimeDirectoryPreserve = "yes";
            Type = "oneshot";
          };

          unitConfig = {
            After = [
              "network-pre.target"
            ]
            ++ optional config.networking.dhcpcd.enable "dhcpcd.service"
            ++ optional config.systemd.network.enable "systemd-networkd.service";

            ConditionPathExists = "!${doMetadataFile}";
          };
        };

        /*
          Set the hostname from Digital Ocean, unless the user configured it in
          the NixOS configuration. The cached metadata file isn't used here
          because the hostname is a mutable part of the droplet.
        */
        systemd.services.digitalocean-set-hostname = mkIf (hostName == "") {
          description = "Set hostname provided by Digitalocean";

          path = [
            pkgs.curl
            pkgs.net-tools
          ];

          script = ''
            set -e
            DIGITALOCEAN_HOSTNAME=$(curl -fsSL http://169.254.169.254/metadata/v1/hostname)
            hostname "$DIGITALOCEAN_HOSTNAME"
            if [[ ! -e /etc/hostname || -w /etc/hostname ]]; then
              printf "%s\n" "$DIGITALOCEAN_HOSTNAME" > /etc/hostname
            fi
          '';

          serviceConfig = {
            Type = "oneshot";
          };

          unitConfig = {
            After = [ "digitalocean-metadata.service" ];
            Before = [ "network.target" ];
            Wants = [ "digitalocean-metadata.service" ];
          };

          wantedBy = [ "network.target" ];
        };

        /*
          Fetch the root password from the digital ocean metadata.
          There is no specific route for this, so we use jq to get
          it from the One Big JSON metadata blob
        */
        systemd.services.digitalocean-set-root-password = mkIf cfg.setRootPassword {
          description = "Set root password provided by Digitalocean";

          path = [
            pkgs.shadow
            pkgs.jq
          ];

          script = ''
            set -eo pipefail
            ROOT_PASSWORD=$(jq -er '.auth_key' ${doMetadataFile})
            echo "root:$ROOT_PASSWORD" | chpasswd
            mkdir -p /etc/do-metadata/set-root-password
          '';

          serviceConfig = {
            Type = "oneshot";
          };

          unitConfig = {
            After = [ "digitalocean-metadata.service" ];
            Before = optional config.services.openssh.enable "sshd.service";
            ConditionPathExists = "!/etc/do-metadata/set-root-password";
            Requires = [ "digitalocean-metadata.service" ];
          };

          wantedBy = [ "multi-user.target" ];
        };

        # Fetch the ssh keys for root from Digital Ocean
        systemd.services.digitalocean-ssh-keys = mkIf cfg.setSshKeys {
          description = "Set root ssh keys provided by Digital Ocean";
          path = [ pkgs.jq ];

          script = ''
            set -e
            mkdir -m 0700 -p /root/.ssh
            jq -er '.public_keys[]' ${doMetadataFile} > /root/.ssh/authorized_keys
            chmod 600 /root/.ssh/authorized_keys
          '';

          serviceConfig = {
            RemainAfterExit = true;
            Type = "oneshot";
          };

          unitConfig = {
            After = [ "digitalocean-metadata.service" ];
            Before = optional config.services.openssh.enable "sshd.service";
            ConditionPathExists = "!/root/.ssh/authorized_keys";
            Requires = [ "digitalocean-metadata.service" ];
          };

          wantedBy = [ "multi-user.target" ];
        };

      }
    ];

  meta.maintainers = with maintainers; [
    arianvp
    eamsden
  ];
}
