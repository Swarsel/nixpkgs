{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  imports = [
    ./disk-size-option.nix
    ../image/file-options.nix
    (lib.mkRenamedOptionModuleWith {
      from = [
        "proxmox"
        "qemuConf"
        "diskSize"
      ];

      sinceRelease = 2411;

      to = [
        "virtualisation"
        "diskSize"
      ];
    })
  ];

  options.proxmox = {
    cloudInit = {
      enable = mkOption {
        default = true;

        description = ''
          Whether the VM should accept cloud init configurations from PVE.
        '';

        type = types.bool;
      };

      defaultStorage = mkOption {
        default = "local-lvm";

        description = ''
          Default storage name for cloud init drive.
        '';

        example = "tank";
        type = types.str;
      };

      device = mkOption {
        default = "ide2";

        description = ''
          Bus/device to which the cloud init drive is attached.
        '';

        example = "scsi0";
        type = types.str;
      };
    };

    filenameSuffix = mkOption {
      default = config.proxmox.qemuConf.name;

      description = ''
        Filename of the image will be vzdump-qemu-''${filenameSuffix}.vma.zstd.
        This will also determine the default name of the VM on restoring the VMA.
        Start this value with a number if you want the VMA to be detected as a backup of
        any specific VMID.
      '';

      example = "999-nixos_template";
      type = types.str;
    };

    partitionTableType = mkOption {
      default = if config.proxmox.qemuConf.bios == "seabios" then "legacy" else "efi";
      defaultText = lib.literalExpression ''if config.proxmox.qemuConf.bios == "seabios" then "legacy" else "efi"'';

      description = ''
        Partition table type to use. See make-disk-image.nix partitionTableType for details.
        Defaults to 'legacy' for 'proxmox.qemuConf.bios="seabios"' (default), other bios values defaults to 'efi'.
        Use 'hybrid' to build grub-based hybrid bios+efi images.
      '';

      example = "hybrid";

      type = types.enum [
        "efi"
        "hybrid"
        "legacy"
        "legacy+gpt"
      ];
    };

    qemuConf = {
      additionalSpace = mkOption {
        default = "512M";

        description = ''
          additional disk space to be added to the image if diskSize "auto"
          is used.
        '';

        example = "2048M";
        type = types.str;
      };

      agent = mkOption {
        apply = x: if x then "1" else "0";
        default = true;

        description = ''
          Expect guest to have qemu agent running
        '';

        type = types.bool;
      };

      bios = mkOption {
        default = "seabios";

        description = ''
          Select BIOS implementation (seabios = Legacy BIOS, ovmf = UEFI).
        '';

        type = types.enum [
          "seabios"
          "ovmf"
        ];
      };

      # essential configs
      boot = mkOption {
        default = "";

        description = ''
          Default boot device. PVE will try all devices in its default order if this value is empty.
        '';

        example = "order=scsi0;net0";
        type = types.str;
      };

      bootSize = mkOption {
        default = "256M";

        description = ''
          Size of the boot partition. Is only used if partitionTableType is
          either "efi" or "hybrid".
        '';

        example = "512M";
        type = types.str;
      };

      cores = mkOption {
        default = 1;

        description = ''
          Guest core count
        '';

        type = types.ints.positive;
      };

      memory = mkOption {
        default = 1024;

        description = ''
          Guest memory in MiB (1024×1024 bytes)
        '';

        type = types.ints.positive;
      };

      # optional configs
      name = mkOption {
        default = "nixos-${config.system.nixos.label}";

        description = ''
          VM name
        '';

        type = types.str;
      };

      net0 = mkOption {
        default = "virtio=00:00:00:00:00:00,bridge=vmbr0,firewall=1";

        description = ''
          Configuration for the default interface. When restoring from VMA, check the
          "unique" box to ensure device mac is randomized.
        '';

        type = types.commas;
      };

      ostype = mkOption {
        default = "l26";

        description = ''
          Guest OS type
        '';

        type = types.str;
      };

      scsihw = mkOption {
        default = "virtio-scsi-single";

        description = ''
          SCSI controller type. Must be one of the supported values given in
          <https://pve.proxmox.com/wiki/Qemu/KVM_Virtual_Machines>
        '';

        example = "lsi";
        type = types.str;
      };

      serial0 = mkOption {
        default = "socket";

        description = ''
          Create a serial device inside the VM (n is 0 to 3), and pass through a host serial device (i.e. /dev/ttyS0),
          or create a unix socket on the host side (use qm terminal to open a terminal connection).
        '';

        example = "/dev/ttyS0";
        type = types.str;
      };

      virtio0 = mkOption {
        default = "local-lvm:vm-9999-disk-0";

        description = ''
          Configuration for the default virtio disk. It can be used as a cue for PVE to autodetect the target storage.
          This parameter is required by PVE even if it isn't used.
        '';

        example = "ceph:vm-123-disk-0";
        type = types.str;
      };
    };

    qemuExtraConf = mkOption {
      default = { };

      description = ''
        Additional options appended to qemu-server.conf
      '';

      example = literalExpression ''
        {
          cpu = "host";
          onboot = 1;
        }
      '';

      type =
        with types;
        attrsOf (oneOf [
          str
          int
        ]);
    };
  };

  config =
    let
      cfg = config.proxmox;
      cfgLine = name: value: ''
        ${name}: ${toString value}
      '';
      virtio0Storage = builtins.head (builtins.split ":" cfg.qemuConf.virtio0);
      cfgFile =
        fileName: properties:
        pkgs.writeTextDir fileName ''
          # generated by NixOS
          ${lib.concatStrings (lib.mapAttrsToList cfgLine properties)}
          #qmdump#map:virtio0:drive-virtio0:${virtio0Storage}:raw:
        '';
      inherit (cfg) partitionTableType;
      supportEfi = partitionTableType == "efi" || partitionTableType == "hybrid";
      supportBios =
        partitionTableType == "legacy"
        || partitionTableType == "hybrid"
        || partitionTableType == "legacy+gpt";
      hasBootPartition = partitionTableType == "efi" || partitionTableType == "hybrid";
      hasNoFsPartition = partitionTableType == "hybrid" || partitionTableType == "legacy+gpt";
      postVM =
        let
          # Build qemu with PVE's patch that adds support for the VMA format
          vma =
            (pkgs.qemu_kvm.override {
              alsaSupport = false;
              gtkSupport = false;
              guestAgentSupport = false;
              jackSupport = false;
              libiscsiSupport = false;
              ncursesSupport = false;
              numaSupport = false;
              pulseSupport = false;
              sdlSupport = false;
              seccompSupport = false;
              smartcardSupport = false;
              spiceSupport = false;
              tpmSupport = false;
              vncSupport = false;
            }).overrideAttrs
              (super: rec {
                buildInputs = super.buildInputs ++ [ pkgs.libuuid ];
                nativeBuildInputs = super.nativeBuildInputs ++ [ pkgs.perl ];

                patches = [
                  # Proxmox' VMA tool is published as a particular patch upon QEMU
                  "${
                    pkgs.fetchFromGitHub {
                      hash = "sha256-lSJQA5SHIHfxJvMLIID2drv2H43crTPMNIlIT37w9Nc=";
                      owner = "proxmox";
                      repo = "pve-qemu";
                      rev = "14afbdd55f04d250bd679ca1ad55d3f47cd9d4c8";
                    }
                  }/debian/patches/pve/0027-PVE-Backup-add-vma-backup-format-code.patch"
                ];

                src = pkgs.fetchurl {
                  hash = "sha256-MnCKxmww2MiSYz6paMdxwcdtWX1w3erSGg0izPOG2mk=";
                  url = "https://download.qemu.org/qemu-${version}.tar.xz";
                };

                # Check https://github.com/proxmox/pve-qemu/tree/master for the version
                # of qemu and patch to use
                version = "9.0.0";

              });
        in
        ''
          ${vma}/bin/vma create "${config.image.baseName}.vma" \
            -c ${
              cfgFile "qemu-server.conf" (cfg.qemuConf // cfg.qemuExtraConf)
            }/qemu-server.conf drive-virtio0=$diskImage
          rm $diskImage
          ${pkgs.zstd}/bin/zstd "${config.image.baseName}.vma"
          mv "${config.image.fileName}" $out/

          mkdir -p $out/nix-support
          echo "file vma $out/${config.image.fileName}" > $out/nix-support/hydra-build-products
        '';
      pveBaseConfigs = {
        inherit (cfg) partitionTableType;
        inherit (cfg.qemuConf) additionalSpace bootSize;
        inherit (config.virtualisation) diskSize;
        inherit config lib pkgs;
        baseName = config.image.baseName;
        format = "raw";
        name = config.image.baseName;
      };
    in
    {
      assertions = [
        {
          assertion = config.boot.loader.systemd-boot.enable -> config.proxmox.qemuConf.bios == "ovmf";
          message = "systemd-boot requires 'ovmf' bios";
        }
        {
          assertion = partitionTableType == "efi" -> config.proxmox.qemuConf.bios == "ovmf";
          message = "'efi' disk partitioning requires 'ovmf' bios";
        }
        {
          assertion = partitionTableType == "legacy" -> config.proxmox.qemuConf.bios == "seabios";
          message = "'legacy' disk partitioning requires 'seabios' bios";
        }
        {
          assertion = partitionTableType == "legacy+gpt" -> config.proxmox.qemuConf.bios == "seabios";
          message = "'legacy+gpt' disk partitioning requires 'seabios' bios";
        }
      ];

      boot = {
        growPartition = true;

        initrd.availableKernelModules = [
          "uas"
          "virtio_blk"
          "virtio_pci"
        ];

        kernelParams = [ "console=ttyS0" ];

        loader.grub = {
          device = lib.mkDefault (
            if (hasNoFsPartition || supportBios) then
              # Even if there is a separate no-fs partition ("/dev/disk/by-partlabel/no-fs" i.e. "/dev/vda2"),
              # which will be used the bootloader, do not set it as loader.grub.device.
              # GRUB installation fails, unless the whole disk is selected.
              "/dev/vda"
            else
              "nodev"
          );

          efiInstallAsRemovable = lib.mkDefault supportEfi;
          efiSupport = lib.mkDefault supportEfi;
        };

        loader.timeout = 0;
      };

      fileSystems."/" = {
        autoResize = true;
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };

      fileSystems."/boot" = lib.mkIf hasBootPartition {
        device = "/dev/disk/by-label/ESP";
        fsType = "vfat";
      };

      image.baseName = lib.mkDefault "vzdump-qemu-${cfg.filenameSuffix}";
      image.extension = "vma.zst";

      networking = mkIf cfg.cloudInit.enable {
        hostName = mkForce "";
        useDHCP = false;
      };

      proxmox.qemuExtraConf.${cfg.cloudInit.device} =
        "${cfg.cloudInit.defaultStorage}:vm-9999-cloudinit,media=cdrom";

      services = {
        cloud-init = mkIf cfg.cloudInit.enable {
          enable = true;
          network.enable = true;
        };

        qemuGuest.enable = true;
        sshd.enable = mkDefault true;
      };

      system.build = {
        VMA = import ../../lib/make-disk-image.nix (
          pveBaseConfigs
          // {
            inherit postVM;
          }
        );

        cloudImage = import ../../lib/make-disk-image.nix pveBaseConfigs;
        image = config.system.build.VMA;
      };
    };
}
