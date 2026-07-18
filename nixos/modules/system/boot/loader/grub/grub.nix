{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  inherit (lib)
    all
    concatMap
    concatMapStrings
    concatStrings
    escapeShellArg
    flip
    foldr
    forEach
    hasPrefix
    mapAttrsToList
    literalExpression
    makeBinPath
    mkDefault
    mkIf
    mkMerge
    mkOption
    mkRemovedOptionModule
    mkRenamedOptionModule
    optional
    optionals
    optionalString
    replaceStrings
    types
    ;

  cfg = config.boot.loader.grub;

  efi = config.boot.loader.efi;

  grubPkgs =
    # Package set of targeted architecture
    if cfg.forcei686 then pkgs.pkgsi686Linux else pkgs;

  realGrub =
    if cfg.zfsSupport then
      grubPkgs.grub2.override {
        zfs = cfg.zfsPackage;
        zfsSupport = true;
      }
    else
      grubPkgs.grub2;

  grub =
    # Don't include GRUB if we're only generating a GRUB menu (e.g.,
    # in EC2 instances).
    if cfg.devices == [ "nodev" ] then null else realGrub;

  grubEfi = if cfg.efiSupport then realGrub.override { efiSupport = cfg.efiSupport; } else null;

  f = x: optionalString (x != null) ("" + x);

  grubConfig =
    args:
    let
      efiSysMountPoint = if args.efiSysMountPoint == null then args.path else args.efiSysMountPoint;
      efiSysMountPoint' = replaceStrings [ "/" ] [ "-" ] efiSysMountPoint;
    in
    pkgs.writeText "grub-config.xml" (
      builtins.toXML {
        inherit efiSysMountPoint;
        inherit (args) devices;
        inherit (efi) canTouchEfiVariables;

        inherit (cfg)
          extraConfig
          extraPerEntryConfig
          extraEntries
          forceInstall
          useOSProber
          extraGrubInstallArgs
          extraEntriesBeforeNixOS
          extraPrepareConfig
          configurationLimit
          copyKernels
          default
          fsIdentifier
          efiSupport
          efiInstallAsRemovable
          gfxmodeEfi
          gfxmodeBios
          gfxpayloadEfi
          gfxpayloadBios
          users
          timeoutStyle
          ;

        backgroundColor = f cfg.backgroundColor;
        bootPath = args.path;

        bootloaderId =
          if args.efiBootloaderId == null then
            "${config.system.nixos.distroName}${efiSysMountPoint'}"
          else
            args.efiBootloaderId;

        entryOptions = f cfg.entryOptions;

        font = lib.optionalString (cfg.font != null) (
          if lib.last (lib.splitString "." cfg.font) == "pf2" then cfg.font else "${convertedFont}"
        );

        fullName = lib.getName realGrub;
        fullVersion = lib.getVersion realGrub;
        # PC platforms (like x86_64-linux) have a non-EFI target (`grubTarget`), but other platforms
        # (like aarch64-linux) have an undefined `grubTarget`. Avoid providing the path to a non-EFI
        # GRUB on those platforms.
        grub = f (if (grub.grubTarget or "") != "" then grub else "");
        grubEfi = f grubEfi;
        grubTarget = f (grub.grubTarget or "");
        grubTargetEfi = optionalString cfg.efiSupport (f (grubEfi.grubTarget or ""));

        path =
          with pkgs;
          makeBinPath (
            [
              coreutils
              gnused
              gnugrep
              findutils
              diffutils
              btrfs-progs
              util-linux
              mdadm
            ]
            ++ optional cfg.efiSupport efibootmgr
            ++ optionals cfg.useOSProber [
              busybox
              os-prober
            ]
          );

        shell = "${pkgs.runtimeShell}";
        splashImage = f cfg.splashImage;
        splashMode = f cfg.splashMode;
        storePath = config.boot.loader.grub.storePath;
        subEntryOptions = f cfg.subEntryOptions;
        theme = f cfg.theme;
        timeout = if config.boot.loader.timeout == null then -1 else config.boot.loader.timeout;
      }
    );

  bootDeviceCounters = foldr (device: attr: attr // { ${device} = (attr.${device} or 0) + 1; }) { } (
    concatMap (args: args.devices) cfg.mirroredBoots
  );

  convertedFont = (
    pkgs.runCommand "grub-font-converted.pf2" { } (
      builtins.concatStringsSep " " (
        [
          "${realGrub}/bin/grub-mkfont"
          cfg.font
          "--output"
          "$out"
        ]
        ++ (optional (cfg.fontSize != null) "--size ${toString cfg.fontSize}")
      )
    )
  );

  defaultSplash = pkgs.nixos-artwork.wallpapers.simple-dark-gray-bootloader.gnomeFilePath;
in

{

  imports = [
    (mkRemovedOptionModule [ "boot" "loader" "grub" "bootDevice" ] "")
    (mkRenamedOptionModule [ "boot" "copyKernels" ] [ "boot" "loader" "grub" "copyKernels" ])
    (mkRenamedOptionModule [ "boot" "extraGrubEntries" ] [ "boot" "loader" "grub" "extraEntries" ])
    (mkRenamedOptionModule
      [ "boot" "extraGrubEntriesBeforeNixos" ]
      [ "boot" "loader" "grub" "extraEntriesBeforeNixOS" ]
    )
    (mkRenamedOptionModule [ "boot" "grubDevice" ] [ "boot" "loader" "grub" "device" ])
    (mkRenamedOptionModule [ "boot" "bootMount" ] [ "boot" "loader" "grub" "bootDevice" ])
    (mkRenamedOptionModule [ "boot" "grubSplashImage" ] [ "boot" "loader" "grub" "splashImage" ])
    (mkRemovedOptionModule [ "boot" "loader" "grub" "trustedBoot" ] ''
      Support for Trusted GRUB has been removed, because the project
      has been retired upstream.
    '')
    (mkRemovedOptionModule [ "boot" "loader" "grub" "extraInitrd" ] ''
      This option has been replaced with the bootloader agnostic
      boot.initrd.secrets option. To migrate to the initrd secrets system,
      extract the extraInitrd archive into your main filesystem:

        # zcat /boot/extra_initramfs.gz | cpio -idvmD /etc/secrets/initrd
        /path/to/secret1
        /path/to/secret2

      then replace boot.loader.grub.extraInitrd with boot.initrd.secrets:

        boot.initrd.secrets = {
          "/path/to/secret1" = "/etc/secrets/initrd/path/to/secret1";
          "/path/to/secret2" = "/etc/secrets/initrd/path/to/secret2";
        };

      See the boot.initrd.secrets option documentation for more information.
    '')
  ];

  ###### interface
  options = {

    boot.loader.grub = {

      enable = mkOption {
        default = !config.boot.isContainer;
        defaultText = literalExpression "!config.boot.isContainer";

        description = ''
          Whether to enable the GNU GRUB boot loader.
        '';

        type = types.bool;
      };

      backgroundColor = mkOption {
        default = null;

        description = ''
          Background color to be used for GRUB to fill the areas the image isn't filling.
        '';

        example = "#7EBAE4";
        type = types.nullOr types.str;
      };

      configurationLimit = mkOption {
        default = 100;

        description = ''
          Maximum of configurations in boot menu. GRUB has problems when
          there are too many entries.
        '';

        example = 120;
        type = types.int;
      };

      configurationName = mkOption {
        default = "";

        description = ''
          GRUB entry name instead of default.
        '';

        example = "Stable 2.6.21";
        type = types.str;
      };

      copyKernels = mkOption {
        default = false;

        description = ''
          Whether the GRUB menu builder should copy kernels and initial
          ramdisks to /boot.  This is done automatically if /boot is
          on a different partition than /.
        '';

        type = types.bool;
      };

      default = mkOption {
        apply = toString;
        default = "0";

        description = ''
          Index of the default menu item to be booted.
          Can also be set to "saved", which will make GRUB select
          the menu item that was used at the last boot.
        '';

        type = types.either types.int types.str;
      };

      device = mkOption {
        default = "";

        description = ''
          The device on which the GRUB boot loader will be installed.
          The special value `nodev` means that a GRUB
          boot menu will be generated, but GRUB itself will not
          actually be installed.  To install GRUB on multiple devices,
          use `boot.loader.grub.devices`.
        '';

        example = "/dev/disk/by-id/wwn-0x500001234567890a";
        type = types.str;
      };

      devices = mkOption {
        default = [ ];

        description = ''
          The devices on which the boot loader, GRUB, will be
          installed. Can be used instead of `device` to
          install GRUB onto multiple devices.
        '';

        example = [ "/dev/disk/by-id/wwn-0x500001234567890a" ];
        type = types.listOf types.str;
      };

      efiInstallAsRemovable = mkOption {
        default = false;

        description = ''
          Whether to invoke `grub-install` with
          `--removable`.

          Unless you turn this on, GRUB will install itself somewhere in
          `boot.loader.efi.efiSysMountPoint` (exactly where
          depends on other config variables). If you've set
          `boot.loader.efi.canTouchEfiVariables` *AND* you
          are currently booted in UEFI mode, then GRUB will use
          `efibootmgr` to modify the boot order in the
          EFI variables of your firmware to include this location. If you are
          *not* booted in UEFI mode at the time GRUB is being installed, the
          NVRAM will not be modified, and your system will not find GRUB at
          boot time. However, GRUB will still return success so you may miss
          the warning that gets printed ("`efibootmgr: EFI variables
          are not supported on this system.`").

          If you turn this feature on, GRUB will install itself in a
          special location within `efiSysMountPoint` (namely
          `EFI/boot/boot$arch.efi`) which the firmwares
          are hardcoded to try first, regardless of NVRAM EFI variables.

          To summarize, turn this on if:
          - You are installing NixOS and want it to boot in UEFI mode,
            but you are currently booted in legacy mode
          - You want to make a drive that will boot regardless of
            the NVRAM state of the computer (like a USB "removable" drive)
          - You simply dislike the idea of depending on NVRAM
            state to make your drive bootable
        '';

        type = types.bool;
      };

      efiSupport = mkOption {
        default = false;

        description = ''
          Whether GRUB should be built with EFI support.
        '';

        type = types.bool;
      };

      enableCryptodisk = mkOption {
        default = false;

        description = ''
          Enable support for encrypted partitions. GRUB should automatically
          unlock the correct encrypted partition and look for filesystems.
        '';

        type = types.bool;
      };

      entryOptions = mkOption {
        default = "--class nixos --unrestricted";

        description = ''
          Options applied to the primary NixOS menu entry.
        '';

        type = types.nullOr types.str;
      };

      extraConfig = mkOption {
        default = "";

        description = ''
          Additional GRUB commands inserted in the configuration file
          just before the menu entries.
        '';

        example = ''
          serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
          terminal_input --append serial
          terminal_output --append serial
        '';

        type = types.lines;
      };

      extraEntries = mkOption {
        default = "";

        description = ''
          Any additional entries you want added to the GRUB boot menu.
        '';

        example = ''
          # GRUB 2 example
          menuentry "Windows 7" {
            chainloader (hd0,4)+1
          }

          # GRUB 2 with UEFI example, chainloading another distro
          menuentry "Fedora" {
            set root=(hd1,1)
            chainloader /efi/fedora/grubx64.efi
          }
        '';

        type = types.lines;
      };

      extraEntriesBeforeNixOS = mkOption {
        default = false;

        description = ''
          Whether extraEntries are included before the default option.
        '';

        type = types.bool;
      };

      extraFiles = mkOption {
        default = { };

        description = ''
          A set of files to be copied to {file}`/boot`.
          Each attribute name denotes the destination file name in
          {file}`/boot`, while the corresponding
          attribute value specifies the source file.
        '';

        example = literalExpression ''
          { "memtest.bin" = pkgs.memtest86plus.efi; }
        '';

        type = types.attrsOf types.path;
      };

      extraGrubInstallArgs = mkOption {
        default = [ ];

        description = ''
          Additional arguments passed to `grub-install`.

          A use case for this is to build specific GRUB2 modules
          directly into the GRUB2 kernel image, so that they are available
          and activated even in the `grub rescue` shell.

          They are also necessary when the BIOS/UEFI is bugged and cannot
          correctly read large disks (e.g. above 2 TB), so GRUB2's own
          `nativedisk` and related modules can be used
          to use its own disk drivers. The example shows one such case.
          This is also useful for booting from USB.
          See the
          [
          GRUB source code
          ](https://git.savannah.gnu.org/cgit/grub.git/tree/grub-core/commands/nativedisk.c?h=grub-2.04#n326)
          for which disk modules are available.

          The list elements are passed directly as `argv`
          arguments to the `grub-install` program, in order.
        '';

        example = [ "--modules=nativedisk ahci pata part_gpt part_msdos diskfilter mdraid1x lvm ext2" ];
        type = types.listOf types.str;
      };

      extraInstallCommands = mkOption {
        default = "";

        description = ''
          Additional shell commands inserted in the bootloader installer
          script after generating menu entries.
        '';

        example = ''
          # the example below generates detached signatures that GRUB can verify
          # https://www.gnu.org/software/grub/manual/grub/grub.html#Using-digital-signatures
          ''${pkgs.findutils}/bin/find /boot -not -path "/boot/efi/*" -type f -name '*.sig' -delete
          old_gpg_home=$GNUPGHOME
          export GNUPGHOME="$(mktemp -d)"
          ''${pkgs.gnupg}/bin/gpg --import ''${priv_key} > /dev/null 2>&1
          ''${pkgs.findutils}/bin/find /boot -not -path "/boot/efi/*" -type f -exec ''${pkgs.gnupg}/bin/gpg --detach-sign "{}" \; > /dev/null 2>&1
          rm -rf $GNUPGHOME
          export GNUPGHOME=$old_gpg_home
        '';

        type = types.lines;
      };

      extraPerEntryConfig = mkOption {
        default = "";

        description = ''
          Additional GRUB commands inserted in the configuration file
          at the start of each NixOS menu entry.
        '';

        example = "root (hd0)";
        type = types.lines;
      };

      extraPrepareConfig = mkOption {
        default = "";

        description = ''
          Additional bash commands to be run at the script that
          prepares the GRUB menu entries.
        '';

        type = types.lines;
      };

      font = mkOption {
        default = "${realGrub}/share/grub/unicode.pf2";
        defaultText = literalExpression ''"''${pkgs.grub2}/share/grub/unicode.pf2"'';

        description = ''
          Path to a TrueType, OpenType, or pf2 font to be used by Grub.
        '';

        type = types.nullOr types.path;
      };

      fontSize = mkOption {
        default = null;

        description = ''
          Font size for the grub menu. Ignored unless `font`
          is set to a ttf or otf font.
        '';

        example = 16;
        type = types.nullOr types.int;
      };

      forceInstall = mkOption {
        default = false;

        description = ''
          Whether to try and forcibly install GRUB even if problems are
          detected. It is not recommended to enable this unless you know what
          you are doing.
        '';

        type = types.bool;
      };

      forcei686 = mkOption {
        default = false;

        description = ''
          Whether to force the use of a ia32 boot loader on x64 systems. Required
          to install and run NixOS on 64bit x86 systems with 32bit (U)EFI.
        '';

        type = types.bool;
      };

      fsIdentifier = mkOption {
        default = "uuid";

        description = ''
          Determines how GRUB will identify devices when generating the
          configuration file. A value of uuid / label signifies that grub
          will always resolve the uuid or label of the device before using
          it in the configuration. A value of provided means that GRUB will
          use the device name as show in {command}`df` or
          {command}`mount`. Note, zfs zpools / datasets are ignored
          and will always be mounted using their labels.
        '';

        type = types.enum [
          "uuid"
          "label"
          "provided"
        ];
      };

      gfxmodeBios = mkOption {
        default = "1024x768";

        description = ''
          The gfxmode to pass to GRUB when loading a graphical boot interface under BIOS.
        '';

        example = "auto";
        type = types.str;
      };

      gfxmodeEfi = mkOption {
        default = "auto";

        description = ''
          The gfxmode to pass to GRUB when loading a graphical boot interface under EFI.
        '';

        example = "1024x768";
        type = types.str;
      };

      gfxpayloadBios = mkOption {
        default = "text";

        description = ''
          The gfxpayload to pass to GRUB when loading a graphical boot interface under BIOS.
        '';

        example = "keep";
        type = types.str;
      };

      gfxpayloadEfi = mkOption {
        default = "keep";

        description = ''
          The gfxpayload to pass to GRUB when loading a graphical boot interface under EFI.
        '';

        example = "text";
        type = types.str;
      };

      mirroredBoots = mkOption {
        default = [ ];

        description = ''
          Mirror the boot configuration to multiple partitions and install grub
          to the respective devices corresponding to those partitions.
        '';

        example = [
          {
            devices = [ "/dev/disk/by-id/wwn-0x500001234567890a" ];
            path = "/boot1";
          }
          {
            devices = [ "/dev/disk/by-id/wwn-0x500009876543210a" ];
            path = "/boot2";
          }
        ];

        type =
          with types;
          listOf (submodule {
            options = {

              devices = mkOption {
                default = [ ];

                description = ''
                  The path to the devices which will have the GRUB MBR written.
                  Note these are typically device paths and not paths to partitions.
                '';

                example = [
                  "/dev/disk/by-id/wwn-0x500001234567890a"
                  "/dev/disk/by-id/wwn-0x500009876543210a"
                ];

                type = types.listOf types.str;
              };

              efiBootloaderId = mkOption {
                default = null;

                description = ''
                  The id of the bootloader to store in efi nvram.
                  The default is to name it NixOS and append the path or efiSysMountPoint.
                  This is only used if `boot.loader.efi.canTouchEfiVariables` is true.
                '';

                example = "NixOS-fsid";
                type = types.nullOr types.str;
              };

              efiSysMountPoint = mkOption {
                default = null;

                description = ''
                  The path to the efi system mount point. Usually this is the same
                  partition as the above path and can be left as null.
                '';

                example = "/boot1/efi";
                type = types.nullOr types.str;
              };

              path = mkOption {
                description = ''
                  The path to the boot directory where GRUB will be written. Generally
                  this boot path should double as an EFI path.
                '';

                example = "/boot1";
                type = types.str;
              };

            };
          });
      };

      splashImage = mkOption {
        description = ''
          Background image used for GRUB.
          Set to `null` to run GRUB in text mode.

          ::: {.note}
          File must be one of .png, .tga, .jpg, or .jpeg. JPEG images must
          not be progressive.
          The image will be scaled if necessary to fit the screen.
          :::
        '';

        example = literalExpression "./my-background.png";
        type = types.nullOr types.path;
      };

      splashMode = mkOption {
        default = "stretch";

        description = ''
          Whether to stretch the image or show the image in the top-left corner unstretched.
        '';

        type = types.enum [
          "normal"
          "stretch"
        ];
      };

      storePath = mkOption {
        default = "/nix/store";

        description = ''
          Path to the Nix store when looking for kernels at boot.
          Only makes sense when copyKernels is false.
        '';

        type = types.str;
      };

      subEntryOptions = mkOption {
        default = "--class nixos";

        description = ''
          Options applied to the secondary NixOS submenu entry.
        '';

        type = types.nullOr types.str;
      };

      theme = mkOption {
        default = null;

        description = ''
          Path to the grub theme to be used.
        '';

        example = literalExpression ''"''${pkgs.kdePackages.breeze-grub}/grub/themes/breeze"'';
        type = types.nullOr types.path;
      };

      timeoutStyle = mkOption {
        default = "menu";

        description = ''
           - `menu` shows the menu.
           - `countdown` uses a text-mode countdown.
           - `hidden` hides GRUB entirely.

          When using a theme, the default value (`menu`) is appropriate for the graphical countdown.

          When attempting to do flicker-free boot, `hidden` should be used.

          See the [GRUB documentation section about `timeout_style`](https://www.gnu.org/software/grub/manual/grub/html_node/timeout.html).

          ::: {.note}
          If this option is set to ‘countdown’ or ‘hidden’ [...] and ESC or F4 are pressed, or SHIFT is held down during that time, it will display the menu and wait for input.
          :::

          From: [Simple configuration handling page, under GRUB_TIMEOUT_STYLE](https://www.gnu.org/software/grub/manual/grub/html_node/Simple-configuration.html).
        '';

        type = types.enum [
          "menu"
          "countdown"
          "hidden"
        ];
      };

      useOSProber = mkOption {
        default = false;

        description = ''
          If set to true, append entries for other OSs detected by os-prober.
        '';

        type = types.bool;
      };

      users = mkOption {
        default = { };

        description = ''
          User accounts for GRUB. When specified, the GRUB command line and
          all boot options except the default are password-protected.
          All passwords and hashes provided will be stored in /boot/grub/grub.cfg,
          and will be visible to any local user who can read this file. Additionally,
          any passwords and hashes provided directly in a Nix configuration
          (as opposed to external files) will be copied into the Nix store, and
          will be visible to all local users.
        '';

        example = {
          root = {
            hashedPasswordFile = "/path/to/file";
          };
        };

        type = types.attrsOf (
          types.submodule {
            options = {
              hashedPassword = mkOption {
                default = null;

                description = ''
                  Specifies the password hash for the account,
                  generated with grub-mkpasswd-pbkdf2.
                  This hash will be copied to the Nix store, and will be visible to all local users.
                '';

                example = "grub.pbkdf2.sha512.10000.674DFFDEF76E13EA...2CC972B102CF4355";
                type = with types; uniq (nullOr str);
              };

              hashedPasswordFile = mkOption {
                default = null;

                description = ''
                  Specifies the path to a file containing the password hash
                  for the account, generated with grub-mkpasswd-pbkdf2.
                  This hash will be stored in /boot/grub/grub.cfg, and will
                  be visible to any local user who can read this file.
                '';

                example = "/path/to/file";
                type = with types; uniq (nullOr str);
              };

              password = mkOption {
                default = null;

                description = ''
                  Specifies the clear text password for the account.
                  This password will be copied to the Nix store, and will be visible to all local users.
                '';

                example = "Pa$$w0rd!";
                type = with types; uniq (nullOr str);
              };

              passwordFile = mkOption {
                default = null;

                description = ''
                  Specifies the path to a file containing the
                  clear text password for the account.
                  This password will be stored in /boot/grub/grub.cfg, and will
                  be visible to any local user who can read this file.
                '';

                example = "/path/to/file";
                type = with types; uniq (nullOr str);
              };
            };
          }
        );
      };

      version = mkOption {
        type = types.int;
        visible = false;
      };

      zfsPackage = mkOption {
        default = pkgs.zfs;
        defaultText = literalExpression "pkgs.zfs";

        description = ''
          Which ZFS package to use if `config.boot.loader.grub.zfsSupport` is true.
        '';

        internal = true;
        type = types.package;
      };

      zfsSupport = mkOption {
        default = false;

        description = ''
          Whether GRUB should be built against libzfs.
        '';

        type = types.bool;
      };

    };

  };

  ###### implementation
  config = mkMerge [

    { boot.loader.grub.splashImage = mkDefault defaultSplash; }

    (mkIf (cfg.splashImage == defaultSplash) {
      boot.loader.grub.backgroundColor = mkDefault "#2F302F";
      boot.loader.grub.splashMode = mkDefault "normal";
    })

    (mkIf cfg.enable {

      assertions = [
        {
          assertion = cfg.mirroredBoots != [ ];

          message =
            "You must set the option ‘boot.loader.grub.devices’ or "
            + "'boot.loader.grub.mirroredBoots' to make the system bootable.";
        }
        {
          assertion =
            cfg.efiSupport
            || all (c: c < 2) (mapAttrsToList (n: c: if n == "nodev" then 0 else c) bootDeviceCounters);

          message = "You cannot have duplicated devices in mirroredBoots";
        }
        {
          assertion = cfg.efiInstallAsRemovable -> cfg.efiSupport;
          message = "If you wish to to use boot.loader.grub.efiInstallAsRemovable, then turn on boot.loader.grub.efiSupport";
        }
        {
          assertion = cfg.efiInstallAsRemovable -> !config.boot.loader.efi.canTouchEfiVariables;
          message = "If you wish to to use boot.loader.grub.efiInstallAsRemovable, then turn off boot.loader.efi.canTouchEfiVariables";
        }
        {
          assertion = !(options.boot.loader.grub.version.isDefined && cfg.version == 1);
          message = "Support for version 0.9x of GRUB was removed after being unsupported upstream for around a decade";
        }
      ]
      ++ flip concatMap cfg.mirroredBoots (
        args:
        [
          {
            assertion = args.devices != [ ];
            message = "A boot path cannot have an empty devices string in ${args.path}";
          }
          {
            assertion = hasPrefix "/" args.path;
            message = "Boot paths must be absolute, not ${args.path}";
          }
          {
            assertion = if args.efiSysMountPoint == null then true else hasPrefix "/" args.efiSysMountPoint;
            message = "EFI paths must be absolute, not ${args.efiSysMountPoint}";
          }
        ]
        ++ forEach args.devices (device: {
          assertion = device == "nodev" || hasPrefix "/" device;
          message = "GRUB devices must be absolute paths, not ${device} in ${args.path}";
        })
      );

      boot.loader.grub.devices = mkIf (cfg.device != "") [ cfg.device ];

      boot.loader.grub.extraPrepareConfig = concatStrings (
        mapAttrsToList (
          fileName: sourcePath:
          flip concatMapStrings cfg.mirroredBoots (
            args:
            let
              efiSysMountPoint = if args.efiSysMountPoint == null then args.path else args.efiSysMountPoint;
            in
            ''
              ${pkgs.coreutils}/bin/install -Dp ${escapeShellArg sourcePath} ${escapeShellArg efiSysMountPoint}/${escapeShellArg fileName}
            ''
          )
        ) config.boot.loader.grub.extraFiles
      );

      boot.loader.grub.mirroredBoots = mkIf (cfg.devices != [ ]) [
        {
          inherit (cfg) devices;
          inherit (efi) efiSysMountPoint;
          path = "/boot";
        }
      ];

      boot.loader.supportsInitrdSecrets = true;
      environment.systemPackages = mkIf (grub != null) [ grub ];
      # Common attribute for boot loaders so only one of them can be
      # set at once.
      system.boot.loader.id = "grub";
      system.build.grub = grub;

      system.build.installBootLoader =
        let
          install-grub-pl = pkgs.replaceVars ./install-grub.pl {
            inherit (config.system.nixos) distroName;
            # targets of a replacement in code
            bootPath = null;
            bootRoot = null;
            btrfsprogs = pkgs.btrfs-progs;
            utillinux = pkgs.util-linux;
          };
          perl = pkgs.perl.withPackages (
            p: with p; [
              FileSlurp
              FileCopyRecursive
              XMLLibXML
              XMLSAX
              XMLSAXBase
              ListCompare
              JSON
            ]
          );
        in
        pkgs.writeScript "install-grub.sh" (
          ''
            #!${pkgs.runtimeShell}
            set -e
            ${optionalString cfg.enableCryptodisk "export GRUB_ENABLE_CRYPTODISK=y"}
          ''
          + flip concatMapStrings cfg.mirroredBoots (args: ''
            ${perl}/bin/perl ${install-grub-pl} ${grubConfig args} $@
          '')
          + cfg.extraInstallCommands
        );

      system.systemBuilderArgs.configurationName = cfg.configurationName;

      system.systemBuilderCommands = ''
        echo -n "$configurationName" > $out/configuration-name
      '';
    })

    (mkIf options.boot.loader.grub.version.isDefined {
      warnings = [
        ''
          The boot.loader.grub.version option does not have any effect anymore, please remove it from your configuration.
        ''
      ];
    })
  ];

}
