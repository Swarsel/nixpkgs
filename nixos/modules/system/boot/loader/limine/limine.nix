{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.boot.loader.limine;
  efi = config.boot.loader.efi;
  limineInstallConfig = pkgs.writeText "limine-install.json" (
    builtins.toJSON {
      inherit (config.system.nixos) distroName;
      additionalFiles = cfg.additionalFiles;
      biosDevice = cfg.biosDevice;
      biosSupport = cfg.biosSupport;
      canTouchEfiVariables = efi.canTouchEfiVariables;
      efiBootMgrPath = pkgs.efibootmgr;
      efiMountPoint = efi.efiSysMountPoint;
      efiRemovable = cfg.efiInstallAsRemovable;
      efiSupport = cfg.efiSupport;
      enableEditor = cfg.enableEditor;
      enrollConfig = cfg.enrollConfig;
      extraConfig = cfg.extraConfig;
      extraEntries = cfg.extraEntries;
      fileSystems = config.fileSystems;
      force = cfg.force;
      hostArchitecture = pkgs.stdenv.hostPlatform.parsed.cpu;
      liminePath = cfg.package;
      luksDevices = builtins.attrNames config.boot.initrd.luks.devices;
      maxGenerations = if cfg.maxGenerations == null then 0 else cfg.maxGenerations;
      nixPath = config.nix.package;
      panicOnChecksumMismatch = cfg.panicOnChecksumMismatch;
      partitionIndex = cfg.partitionIndex;
      resolution = cfg.resolution;
      secureBoot = cfg.secureBoot;
      style = cfg.style;
      timeout = if config.boot.loader.timeout == null then "no" else config.boot.loader.timeout;
      validateChecksums = cfg.validateChecksums;
    }
  );
  defaultWallpaper = pkgs.nixos-artwork.wallpapers.simple-dark-gray-bootloader.gnomeFilePath;
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "boot" "loader" "limine" "forceMbr" ]
      [ "boot" "loader" "limine" "force" ]
    )
  ];

  options.boot.loader.limine = {
    enable = lib.mkEnableOption "the Limine Bootloader";
    package = lib.mkPackageOption pkgs "limine" { };

    additionalFiles = lib.mkOption {
      default = { };

      description = ''
        A set of files to be copied to {file}`/boot`. Each attribute name denotes the
        destination file name in {file}`/boot`, while the corresponding attribute value
        specifies the source file.
      '';

      example = lib.literalExpression ''
        { "efi/memtest86/memtest86.efi" = "''${pkgs.memtest86-efi}/BOOTX64.efi"; }
      '';

      type = lib.types.attrsOf lib.types.path;
    };

    biosDevice = lib.mkOption {
      default = "nodev";

      description = ''
        Device to install the BIOS version of limine on.
      '';

      type = lib.types.str;
    };

    biosSupport = lib.mkEnableOption null // {
      default = !cfg.efiSupport && pkgs.stdenv.hostPlatform.isx86;
      defaultText = lib.literalExpression "!config.boot.loader.limine.efiSupport && pkgs.stdenv.hostPlatform.isx86";

      description = ''
        Whether or not to install limine for BIOS.
      '';
    };

    efiInstallAsRemovable = lib.mkEnableOption null // {
      default = !efi.canTouchEfiVariables;
      defaultText = lib.literalExpression "!config.boot.loader.efi.canTouchEfiVariables";

      description = ''
        Whether or not to install the limine EFI files as removable.

        See {option}`boot.loader.grub.efiInstallAsRemovable`
      '';
    };

    efiSupport = lib.mkEnableOption null // {
      default = pkgs.stdenv.hostPlatform.isEfi;
      defaultText = lib.literalExpression "pkgs.stdenv.hostPlatform.isEfi";

      description = ''
        Whether or not to install the limine EFI files.
      '';
    };

    enableEditor = lib.mkEnableOption null // {
      description = ''
        Whether to allow editing the boot entries before booting them.
        It is recommended to set this to false, as it allows gaining root
        access by passing `init=/bin/sh` as a kernel parameter.
      '';
    };

    enrollConfig = lib.mkEnableOption null // {
      default = cfg.panicOnChecksumMismatch;
      defaultText = lib.literalExpression "boot.loader.limine.panicOnChecksumMismatch";

      description = ''
        Whether or not to enroll the config.
        Only works on EFI!
      '';
    };

    extraConfig = lib.mkOption {
      default = "";

      description = ''
        A string which is prepended to limine.conf. The config format can be found [here](https://github.com/limine-bootloader/limine/blob/trunk/CONFIG.md).
      '';

      example = lib.literalExpression ''
        serial: yes
      '';

      type = lib.types.lines;
    };

    extraEntries = lib.mkOption {
      default = "";

      description = ''
        A string which is appended to the end of limine.conf. The config format can be found [here](https://github.com/limine-bootloader/limine/blob/trunk/CONFIG.md).
      '';

      example = lib.literalExpression ''
        /memtest86
          protocol: chainload
          path: boot():///efi/memtest86/memtest86.efi
      '';

      type = lib.types.lines;
    };

    extraInstallCommands = lib.mkOption {
      default = "";

      description = ''
        Additional shell commands inserted in the bootloader installer
        script after generating menu entries. It can be used to expand
        on extra boot entries that cannot incorporate certain pieces of
        information (such as the resulting `init=` kernel parameter).
      '';

      type = lib.types.lines;
    };

    force = lib.mkEnableOption null // {
      description = ''
        Force installation even if the safety checks fail, use absolutely only if necessary!
      '';
    };

    maxGenerations = lib.mkOption {
      default = null;

      description = ''
        Maximum number of latest generations in the boot menu.
        Useful to prevent boot partition of running out of disk space.
        `null` means no limit i.e. all generations that were not
        garbage collected yet.
      '';

      example = 50;
      type = lib.types.nullOr lib.types.int;
    };

    panicOnChecksumMismatch = lib.mkEnableOption null // {
      description = ''
        Whether or not checksum validation failure should be a fatal
        error at boot time.
      '';
    };

    partitionIndex = lib.mkOption {
      default = null;

      description = ''
        The 1-based index of the dedicated partition for limine's second stage.
      '';

      type = lib.types.nullOr lib.types.int;
    };

    resolution = lib.mkOption {
      default = null;

      description = ''
        The framebuffer resolution to set when booting Linux entries.
        This controls the GOP mode that Limine sets before handing off to the kernel,
        which affects early boot graphics (e.g., simpledrm, efifb).

        Format: `<width>x<height>` or `<width>x<height>x<bpp>`.
        If bpp is omitted, defaults to 32.

        Note: Refresh rate is not supported because the UEFI GOP protocol only
        defines framebuffer dimensions and pixel format, not display timing.
        Refresh rate is determined later by the GPU driver based on EDID.

        This is distinct from {option}`boot.loader.limine.style.interface.resolution`
        which only affects the Limine bootloader's own menu interface.
      '';

      example = "1920x1080x32";
      type = lib.types.nullOr lib.types.str;
    };

    secureBoot = {
      enable = lib.mkEnableOption null // {
        description = ''
          Whether to use sign the limine binary with sbctl.

          ::: {.note}
          This requires you to already have generated the keys and enrolled them with {command}`sbctl`.

          To create keys use {command}`sbctl create-keys`.

          To enroll them first reset secure boot to "Setup Mode". This is device specific.
          Then enroll them using {command}`sbctl enroll-keys -m -f`.

          You can now rebuild your system with this option enabled.

          Afterwards turn setup mode off and enable secure boot.
          :::
        '';
      };

      autoEnrollKeys = {
        enable = lib.mkEnableOption null // {
          description = "Enroll automatically generated keys";
        };

        extraArgs = lib.mkOption {
          default = [
            "--microsoft"
            "--firmware-builtin"
          ];

          description = "Extra arguments passed to sbctl";
          type = lib.types.listOf lib.types.str;
        };
      };

      autoGenerateKeys = lib.mkEnableOption null // {
        description = "Generate keys automatically when none exists during bootloader installation";
      };

      sbctl = lib.mkPackageOption pkgs "sbctl" { };
    };

    style = {
      backdrop = lib.mkOption {
        default = null;

        description = ''
          Color to fill the rest of the screen with when wallpaper_style is centered in RRGGBB format.
        '';

        example = "7EBAE4";
        type = lib.types.nullOr lib.types.str;
      };

      graphicalTerminal = {
        background = lib.mkOption {
          default = null;

          description = ''
            Text background color (TTRRGGBB). TT is transparency.
          '';

          type = lib.types.nullOr lib.types.str;
        };

        brightBackground = lib.mkOption {
          default = null;

          description = ''
            Text background bright color (RRGGBB).
          '';

          type = lib.types.nullOr lib.types.str;
        };

        brightForeground = lib.mkOption {
          default = null;

          description = ''
            Text foreground bright color (RRGGBB).
          '';

          type = lib.types.nullOr lib.types.str;
        };

        brightPalette = lib.mkOption {
          default = null;

          description = ''
            A ; seperated array of 8 colors in the format RRGGBB:
            dark gray, bright red, bright green, yellow, bright blue, bright magenta, bright cyan, and white.
          '';

          type = lib.types.nullOr lib.types.str;
        };

        font = {
          scale = lib.mkOption {
            default = null;

            description = ''
              The scale of the font in the format <width>x<height>.
            '';

            example = lib.literalExpression "2x2";
            type = lib.types.nullOr lib.types.str;
          };

          spacing = lib.mkOption {
            default = null;

            description = ''
              The horizontal spacing between characters in pixels.
            '';

            type = lib.types.nullOr lib.types.int;
          };
        };

        foreground = lib.mkOption {
          default = null;

          description = ''
            Text foreground color (RRGGBB).
          '';

          type = lib.types.nullOr lib.types.str;
        };

        margin = lib.mkOption {
          default = null;

          description = ''
            The amount of margin around the terminal.
          '';

          type = lib.types.nullOr lib.types.int;
        };

        marginGradient = lib.mkOption {
          default = null;

          description = ''
            The thickness in pixels for the margin around the terminal.
          '';

          type = lib.types.nullOr lib.types.int;
        };

        palette = lib.mkOption {
          default = null;

          description = ''
            A ; seperated array of 8 colors in the format RRGGBB:
            black, red, green, brown, blue, magenta, cyan, and gray.
          '';

          type = lib.types.nullOr lib.types.str;
        };
      };

      interface = {
        branding = lib.mkOption {
          default = null;

          description = ''
            The title at the top of the screen.
          '';

          type = lib.types.nullOr lib.types.str;
        };

        brandingColor = lib.mkOption {
          default = null;

          description = ''
            Color of the title at the top of the screen in RRGGBB format (Limine defaults to #00AAAA (cyan)).
          '';

          type = lib.types.nullOr lib.types.str;
        };

        helpColor = lib.mkOption {
          default = null;

          description = ''
            Color of the help text displayed beside keybinds in RRGGBB format (Limine defaults to #00AA00 (dark green)).
          '';

          type = lib.types.nullOr lib.types.str;
        };

        helpColorBright = lib.mkOption {
          default = null;

          description = ''
            Color of the bright help text used for the auto-boot countdown digit in RRGGBB format (Limine defaults to #55FF55 (bright green)).
          '';

          type = lib.types.nullOr lib.types.str;
        };

        helpHidden = lib.mkEnableOption null // {
          description = ''
            Whether or not to hide the keybinds at the top of the screen.
          '';
        };

        resolution = lib.mkOption {
          default = null;

          description = ''
            The resolution of the interface.
          '';

          type = lib.types.nullOr lib.types.str;
        };
      };

      wallpaperStyle = lib.mkOption {
        default = "stretched";

        description = ''
          How the wallpaper should be fit to the screen.
        '';

        type = lib.types.enum [
          "centered"
          "stretched"
          "tiled"
        ];
      };

      wallpapers = lib.mkOption {
        default = [ ];

        description = ''
          A list of wallpapers.
          If more than one is specified, a random one will be selected at boot.
        '';

        example = lib.literalExpression "[ pkgs.nixos-artwork.wallpapers.simple-dark-gray-bootloader.gnomeFilePath ]";
        type = lib.types.listOf lib.types.path;
      };
    };

    validateChecksums = lib.mkEnableOption null // {
      default = true;

      description = ''
        Whether to validate file checksums before booting.
      '';
    };
  };

  config = lib.mkMerge [
    {
      boot.loader.limine.style.wallpapers = lib.mkDefault [ defaultWallpaper ];
    }
    (lib.mkIf (cfg.style.wallpapers == [ defaultWallpaper ]) {
      boot.loader.limine.style.backdrop = lib.mkDefault "2F302F";
      boot.loader.limine.style.wallpaperStyle = lib.mkDefault "stretched";
    })
    (lib.mkIf cfg.enable {
      assertions = [
        {
          assertion =
            pkgs.stdenv.hostPlatform.isx86_64
            || pkgs.stdenv.hostPlatform.isi686
            || pkgs.stdenv.hostPlatform.isAarch64;

          message = "Limine can only be installed on aarch64 & x86 platforms";
        }
        {
          assertion = cfg.efiSupport || cfg.biosSupport;
          message = "Both UEFI support and BIOS support for Limine are disabled, this will result in an unbootable system";
        }
      ];

      boot.loader.grub.enable = lib.mkDefault false;
      boot.loader.supportsInitrdSecrets = true;

      system = {
        boot.loader.id = "limine";

        build.installBootLoader =
          let
            install = pkgs.replaceVarsWith {
              isExecutable = true;

              replacements = {
                configPath = limineInstallConfig;
                python3 = pkgs.python3.withPackages (python-packages: [ python-packages.psutil ]);
              };

              src = ./limine-install.py;
            };

            final = pkgs.writeScript "limine-install.sh" ''
              #!${pkgs.runtimeShell}
              set -euo pipefail
              ${install} "$@"
              ${cfg.extraInstallCommands}
            '';
          in
          final;
      };
    })
    (lib.mkIf (cfg.enable && cfg.secureBoot.enable) {
      assertions = [
        {
          assertion = cfg.enrollConfig;
          message = "Disabling enrollConfig allows bypassing secure boot.";
        }
        {
          assertion = cfg.validateChecksums;
          message = "Disabling validateChecksums allows bypassing secure boot.";
        }
        {
          assertion = cfg.panicOnChecksumMismatch;
          message = "Disabling panicOnChecksumMismatch allows bypassing secure boot.";
        }
        {
          assertion = cfg.efiSupport;
          message = "Secure boot is only supported on EFI systems.";
        }
        {
          assertion = !cfg.enableEditor;
          message = "Editor is unconditionally disabled by Limine.";
        }
      ];

      boot.loader.limine.enrollConfig = true;
      boot.loader.limine.panicOnChecksumMismatch = true;
      boot.loader.limine.validateChecksums = true;
    })

    # Fwupd binary needs to be signed in secure boot mode
    (lib.mkIf (cfg.enable && cfg.secureBoot.enable && config.services.fwupd.enable) {
      services.fwupd.uefiCapsuleSettings = {
        DisableShimForSecureBoot = true;
      };

      systemd.services.fwupd = {
        environment.FWUPD_EFIAPPDIR = "/run/fwupd-efi";
      };

      systemd.services.fwupd-efi = {
        before = [ "fwupd.service" ];
        description = "Sign fwupd EFI app for secure boot";
        partOf = [ "fwupd.service" ];

        script = ''
          fwupd_efi=(${config.services.fwupd.package.fwupd-efi}/libexec/fwupd/efi/fwupd*.efi)
          for efi in "''${fwupd_efi[@]}"; do
            ${lib.getExe cfg.secureBoot.sbctl} sign -o "/run/fwupd-efi/$(basename "$efi").signed" "$efi"
          done
        '';

        serviceConfig = {
          RemainAfterExit = true;
          RuntimeDirectory = "fwupd-efi";
          Type = "oneshot";
        };

        unitConfig.ConditionPathIsDirectory = "/var/lib/sbctl";
        wantedBy = [ "fwupd.service" ];
      };
    })
    (lib.mkIf (cfg.enable && cfg.secureBoot.enable && cfg.secureBoot.autoEnrollKeys.enable) {
      assertions = [
        {
          assertion = cfg.secureBoot.autoGenerateKeys;
          message = "autoEnrollKeys doesn't do anything without autoGenerateKeys.";
        }
      ];

      boot.loader.limine.secureBoot.autoGenerateKeys = true;
    })
  ];

  meta = {
    inherit (pkgs.limine.meta) maintainers;
  };
}
