{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.virtualbox;
in
{
  imports = [
    ./disk-size-option.nix
    ../image/file-options.nix
    (lib.mkRenamedOptionModuleWith {
      from = [
        "virtualbox"
        "baseImageSize"
      ];

      sinceRelease = 2411;

      to = [
        "virtualisation"
        "diskSize"
      ];
    })
    (lib.mkRenamedOptionModuleWith {
      from = [
        "virtualisation"
        "virtualbox"
        "vmFileName"
      ];

      sinceRelease = 2505;

      to = [
        "image"
        "fileName"
      ];
    })
  ];

  options = {
    virtualbox = {
      baseImageFreeSpace = lib.mkOption {
        default = 30 * 1024;

        description = ''
          Free space in the VirtualBox base image in MiB.
        '';

        type = lib.types.int;
      };

      exportParams = lib.mkOption {
        default = [ ];

        description = ''
          Parameters passed to the Virtualbox export command.

          Run `VBoxManage export --help` to see more options.
        '';

        example = [
          "--vsys"
          "0"
          "--vendor"
          "ACME Inc."
        ];

        type =
          with lib.types;
          listOf (oneOf [
            str
            int
            bool
            (listOf str)
          ]);
      };

      extraDisk = lib.mkOption {
        default = null;

        description = ''
          Optional extra disk/hdd configuration.
          The disk will be an 'ext4' partition on a separate file.
        '';

        example = {
          label = "storage";
          mountPoint = "/home/demo/storage";
          size = 100 * 1024;
        };

        type = lib.types.nullOr (
          lib.types.submodule {
            options = {
              label = lib.mkOption {
                default = "vm-extra-storage";
                description = "Label for the disk partition";
                type = lib.types.str;
              };

              mountPoint = lib.mkOption {
                description = "Path where to mount this disk.";
                type = lib.types.str;
              };

              size = lib.mkOption {
                description = "Size in MiB";
                type = lib.types.int;
              };
            };
          }
        );
      };

      memorySize = lib.mkOption {
        default = 1536;

        description = ''
          The amount of RAM the VirtualBox appliance can use in MiB.
        '';

        type = lib.types.int;
      };

      params = lib.mkOption {
        description = ''
          Parameters passed to the Virtualbox appliance.

          Run `VBoxManage modifyvm --help` to see more options.
        '';

        example = {
          audio = "alsa";
          rtcuseutc = "on";
          usb = "off";
        };

        type =
          with lib.types;
          attrsOf (oneOf [
            str
            int
            bool
            (listOf str)
          ]);
      };

      postExportCommands = lib.mkOption {
        default = "";

        description = ''
          Extra commands to run after exporting the OVA to `$fn`.
        '';

        example = ''
          ${pkgs.cot}/bin/cot edit-hardware "$fn" \
            -v vmx-14 \
            --nics 2 \
            --nic-types VMXNET3 \
            --nic-names 'Nic name' \
            --nic-networks 'Nic match' \
            --network-descriptions 'Nic description' \
            --scsi-subtypes VirtualSCSI
        '';

        type = lib.types.lines;
      };

      storageController = lib.mkOption {
        default = {
          add = "sata";
          bootable = "on";
          hostiocache = "on";
          name = "SATA";
          portcount = 4;
        };

        description = ''
          Parameters passed to the VirtualBox appliance. Must have at least
          `name`.

          Run `VBoxManage storagectl --help` to see more options.
        '';

        example = {
          add = "scsi";
          bootable = "on";
          hostiocache = "on";
          name = "SCSI";
          portcount = 16;
        };

        type =
          with lib.types;
          attrsOf (oneOf [
            str
            int
            bool
            (listOf str)
          ]);
      };

      vmDerivationName = lib.mkOption {
        default = "nixos-ova-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}";

        description = ''
          The name of the derivation for the VirtualBox appliance.
        '';

        type = lib.types.str;
      };

      vmName = lib.mkOption {
        default = "${config.system.nixos.distroName} ${config.system.nixos.label} (${pkgs.stdenv.hostPlatform.system})";

        description = ''
          The name of the VirtualBox appliance.
        '';

        type = lib.types.str;
      };
    };
  };

  config = {
    boot.growPartition = true;
    boot.loader.grub.device = "/dev/sda";

    fileSystems = {
      "/" = {
        autoResize = true;
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };
    }
    // (lib.optionalAttrs (cfg.extraDisk != null) {
      ${cfg.extraDisk.mountPoint} = {
        autoResize = true;
        device = "/dev/disk/by-label/" + cfg.extraDisk.label;
        fsType = "ext4";
      };
    });

    image.extension = "ova";

    swapDevices = [
      {
        device = "/var/swap";
        size = 2048;
      }
    ];

    system.build.image = lib.mkDefault config.system.build.virtualBoxOVA;

    system.build.virtualBoxOVA = import ../../lib/make-disk-image.nix {
      inherit pkgs lib config;
      inherit (config.virtualisation) diskSize;
      additionalSpace = "${toString cfg.baseImageFreeSpace}M";
      baseName = config.image.baseName;
      name = cfg.vmDerivationName;
      partitionTableType = "legacy";

      postVM = ''
        export HOME=$PWD
        export PATH=${pkgs.virtualbox}/bin:$PATH

        echo "converting image to VirtualBox format..."
        VBoxManage convertfromraw $diskImage disk.vdi

        ${lib.optionalString (cfg.extraDisk != null) ''
          echo "creating extra disk: data-disk.raw"
          dataDiskImage=data-disk.raw
          truncate -s ${toString cfg.extraDisk.size}M $dataDiskImage

          parted --script $dataDiskImage -- \
            mklabel msdos \
            mkpart primary ext4 1MiB -1
          eval $(partx $dataDiskImage -o START,SECTORS --nr 1 --pairs)
          mkfs.ext4 -F -L ${cfg.extraDisk.label} $dataDiskImage -E offset=$(sectorsToBytes $START) $(sectorsToKilobytes $SECTORS)K
          echo "creating extra disk: data-disk.vdi"
          VBoxManage convertfromraw $dataDiskImage data-disk.vdi
        ''}

        echo "creating VirtualBox VM..."
        vmName="${cfg.vmName}";
        VBoxManage createvm --name "$vmName" --register \
          --ostype ${if pkgs.stdenv.hostPlatform.system == "x86_64-linux" then "Linux26_64" else "Linux26"}
        VBoxManage modifyvm "$vmName" \
          --memory ${toString cfg.memorySize} \
          ${lib.cli.toCommandLineShellGNU { } cfg.params}
        VBoxManage storagectl "$vmName" ${lib.cli.toCommandLineShellGNU { } cfg.storageController}
        VBoxManage storageattach "$vmName" --storagectl ${cfg.storageController.name} --port 0 --device 0 --type hdd \
          --medium disk.vdi
        ${lib.optionalString (cfg.extraDisk != null) ''
          VBoxManage storageattach "$vmName" --storagectl ${cfg.storageController.name} --port 1 --device 0 --type hdd \
          --medium data-disk.vdi
        ''}

        echo "exporting VirtualBox VM..."
        mkdir -p $out
        fn="$out/${config.image.fileName}"
        VBoxManage export "$vmName" --output "$fn" --options manifest ${lib.escapeShellArgs cfg.exportParams}
        ${cfg.postExportCommands}

        rm -v $diskImage

        mkdir -p $out/nix-support
        echo "file ova $fn" >> $out/nix-support/hydra-build-products
      '';
    };

    system.nixos.tags = [ "virtualbox" ];

    virtualbox.params = lib.mkMerge [
      (lib.mapAttrs (name: lib.mkDefault) {
        acpi = "on";
        audio = "alsa";
        audiocontroller = "ac97";
        audioout = "on";
        graphicscontroller = "vmsvga";
        mouse = "usbtablet";
        nic1 = "nat";
        nictype1 = "virtio";
        rtcuseutc = "on";
        usb = "on";
        usbehci = "on";
        vram = 32;
      })
      (lib.mkIf (pkgs.stdenv.hostPlatform.system == "i686-linux") { pae = "on"; })
    ];

    # Use a priority just below mkOptionDefault (1500) instead of lib.mkDefault
    # to avoid breaking existing configs using that.
    virtualisation.diskSize = lib.mkOverride 1490 (50 * 1024);
    virtualisation.virtualbox.guest.enable = true;

  };
}
