{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  inherit (config.boot) kernelPatches;
  inherit (config.boot.kernel) features randstructSeed;
  inherit (config.boot.kernelPackages) kernel;

  modulesTypeDesc = ''
    This can either be a list of modules, or an attrset. In an
    attrset, names that are set to `true` represent modules that will
    be included. Note that setting these names to `false` does not
    prevent the module from being loaded. For that, use
    {option}`boot.blacklistedKernelModules`.
  '';

  kernelModulesConf = pkgs.writeText "nixos.conf" ''
    ${concatStringsSep "\n" config.boot.kernelModules}
  '';

  # A list of attrnames is coerced into an attrset of bools by
  # setting the values to true.
  attrNamesToTrue = types.coercedTo (types.listOf types.str) (
    enabledList: lib.genAttrs enabledList (_attrName: true)
  ) (types.attrsOf types.bool);

in

{

  imports = [
    (mkRemovedOptionModule [ "boot" "vesa" ] ''
      The `boot.vesa` option has been removed. It was deprecated in 2020
      because Xorg now works better with kernel modesetting. If you still
      need the legacy VESA 800x600 fallback, set
      `boot.kernelParams = [ "vga=0x317" "nomodeset" ];` directly.
    '')
  ];

  ###### interface

  options = {
    boot.consoleLogLevel = mkOption {
      default = 4;

      description = ''
        The kernel console `loglevel`. All Kernel Messages with a log level smaller
        than this setting will be printed to the console.
      '';

      type = types.int;
    };

    boot.extraModulePackages = mkOption {
      default = [ ];
      description = "A list of additional packages supplying kernel modules.";
      example = literalExpression "[ config.boot.kernelPackages.nvidia_x11 ]";
      type = types.listOf types.package;
    };

    boot.initrd.allowMissingModules = mkOption {
      default = false;

      description = ''
        Whether the initrd can be built even though modules listed in
        {option}`boot.initrd.kernelModules` or
        {option}`boot.initrd.availableKernelModules` are missing from
        the kernel. This is useful when combining configurations that
        include a lot of modules, such as
        {option}`hardware.enableAllHardware`, with kernels that don't
        provide as many modules as typical NixOS kernels.

        Note that enabling this is discouraged. Instead, try disabling
        individual modules by setting e.g.
        `boot.initrd.availableKernelModules.foo = lib.mkForce false;`
      '';

      type = types.bool;
    };

    boot.initrd.availableKernelModules = mkOption {
      apply = mods: lib.attrNames (lib.filterAttrs (_: v: v) mods);
      default = { };

      description = ''
        The set of kernel modules in the initial ramdisk used during the
        boot process.  This set must include all modules necessary for
        mounting the root device.  That is, it should include modules
        for the physical device (e.g., SCSI drivers) and for the file
        system (e.g., ext3).  The set specified here is automatically
        closed under the module dependency relation, i.e., all
        dependencies of the modules list here are included
        automatically.  The modules listed here are available in the
        initrd, but are only loaded on demand (e.g., the ext3 module is
        loaded automatically when an ext3 filesystem is mounted, and
        modules for PCI devices are loaded when they match the PCI ID
        of a device in your system).  To force a module to be loaded,
        include it in {option}`boot.initrd.kernelModules`.

        ${modulesTypeDesc}
      '';

      example = [
        "sata_nv"
        "ext3"
      ];

      type = attrNamesToTrue;
    };

    boot.initrd.includeDefaultModules = mkOption {
      default = true;

      description = ''
        This option, if set, adds a collection of default kernel modules
        to {option}`boot.initrd.availableKernelModules` and
        {option}`boot.initrd.kernelModules`.
      '';

      type = types.bool;
    };

    boot.initrd.kernelModules = mkOption {
      apply = mods: lib.attrNames (lib.filterAttrs (_: v: v) mods);
      default = { };

      description = ''
        Set of modules that are always loaded by the initrd.

        ${modulesTypeDesc}
      '';

      type = attrNamesToTrue;
    };

    boot.kernel.enable =
      mkEnableOption "the Linux kernel. This is useful for systemd-like containers which do not require a kernel"
      // {
        default = true;
      };

    boot.kernel.features = mkOption {
      default = { };

      description = ''
        This option allows to enable or disable certain kernel features.
        It's not API, because it's about kernel feature sets, that
        make sense for specific use cases. Mostly along with programs,
        which would have separate nixos options.
        `grep features pkgs/os-specific/linux/kernel/common-config.nix`
      '';

      example = literalExpression "{ debug = true; }";
      internal = true;
    };

    boot.kernel.randstructSeed = mkOption {
      default = "";

      description = ''
        Provides a custom seed for the {var}`RANDSTRUCT` security
        option of the Linux kernel. Note that {var}`RANDSTRUCT` is
        only enabled in NixOS hardened kernels. Using a custom seed requires
        building the kernel and dependent packages locally, since this
        customization happens at build time.
      '';

      example = "my secret seed";
      type = types.str;
    };

    boot.kernelModules = mkOption {
      apply = mods: lib.attrNames (lib.filterAttrs (_: v: v) mods);
      default = { };

      description = ''
        The set of kernel modules to be loaded in the second stage of
        the boot process.  Note that modules that are needed to
        mount the root file system should be added to
        {option}`boot.initrd.availableKernelModules` or
        {option}`boot.initrd.kernelModules`.

        ${modulesTypeDesc}
      '';

      type = attrNamesToTrue;
    };

    boot.kernelPackages = mkOption {
      apply =
        kernelPackages:
        kernelPackages.extend (
          self: super: {
            kernel = super.kernel.override (originalArgs: {
              inherit randstructSeed;
              features = lib.recursiveUpdate super.kernel.features features;
              kernelPatches = (originalArgs.kernelPatches or [ ]) ++ kernelPatches;
            });
          }
        );

      default = pkgs.linuxPackages;
      # We don't want to evaluate all of linuxPackages for the manual
      # - some of it might not even evaluate correctly.
      defaultText = literalExpression "pkgs.linuxPackages";

      description = ''
        This option allows you to override the Linux kernel used by
        NixOS.  Since things like external kernel module packages are
        tied to the kernel you're using, it also overrides those.
        This option is a function that takes Nixpkgs as an argument
        (as a convenience), and returns an attribute set containing at
        the very least an attribute {var}`kernel`.
        Additional attributes may be needed depending on your
        configuration.  For instance, if you use the NVIDIA X driver,
        then it also needs to contain an attribute
        {var}`nvidia_x11`.

        Please note that we strictly support kernel versions that are
        maintained by the Linux developers only. More information on the
        availability of kernel versions is documented
        [in the Linux section of the manual](https://nixos.org/manual/nixos/unstable/index.html#sec-kernel-config).
      '';

      example = literalExpression "pkgs.linuxKernel.packages.linux_5_10";
      type = types.raw;
    };

    boot.kernelParams = mkOption {
      default = [ ];
      description = "Parameters added to the kernel command line.";

      type = types.listOf (
        types.strMatching ''([^"[:space:]]|"[^"]*")+''
        // {
          description = "string, with spaces inside double quotes";
          name = "kernelParam";
        }
      );
    };

    boot.kernelPatches = mkOption {
      default = [ ];

      description = ''
        A list of additional patches to apply to the kernel.

        Every item should be an attribute set with the following attributes:

        ```nix
        {
          name = "foo";                 # descriptive name, required

          patch = ./foo.patch;          # path or derivation that contains the patch source
                                        # (required, but can be null if only config changes
                                        # are needed)

          structuredExtraConfig = {     # attrset of extra configuration parameters without the CONFIG_ prefix
            FOO = lib.kernel.yes;       # (optional)
          };                            # values should generally be lib.kernel.yes,
                                        # lib.kernel.no or lib.kernel.module

          features = {                  # attrset of extra "features" the kernel is considered to have
            foo = true;                 # (may be checked by other NixOS modules, optional)
          };

          extraConfig = "FOO y";        # extra configuration options in string form without the CONFIG_ prefix
                                        # (optional, multiple lines allowed to specify multiple options)
                                        # (deprecated, use structuredExtraConfig instead)
        }
        ```

        There's a small set of existing kernel patches in Nixpkgs, available as `pkgs.kernelPatches`,
        that follow this format and can be used directly.
      '';

      example = literalExpression ''
        [
          {
            name = "foo";
            patch = ./foo.patch;
            structuredExtraConfig.FOO = lib.kernel.yes;
            features.foo = true;
          }
          {
            name = "foo-ml-mbox";
            patch = (fetchurl {
              url = "https://lore.kernel.org/lkml/19700205182810.58382-1-email@domain/t.mbox.gz";
              hash = "sha256-...";
            });
          }
        ]
      '';

      type = types.listOf types.attrs;
    };

    system.modulesTree = mkOption {
      # Convert the list of path to only one path.
      apply =
        let
          kernel-name = config.boot.kernelPackages.kernel.name or "kernel";
        in
        modules: (pkgs.aggregateModules modules).override { name = kernel-name + "-modules"; };

      default = [ ];

      description = ''
        Tree of kernel modules.  This includes the kernel, plus modules
        built outside of the kernel.  Combine these into a single tree of
        symlinks because modprobe only supports one directory.
      '';

      internal = true;
      type = types.listOf types.path;
    };

    system.requiredKernelConfig = mkOption {
      default = [ ];

      description = ''
        This option allows modules to specify the kernel config options that
        must be set (or unset) for the module to work. Please use the
        lib.kernelConfig functions to build list elements.
      '';

      example = literalExpression ''
        with config.lib.kernelConfig; [
          (isYes "MODULES")
          (isEnabled "FB_CON_DECOR")
          (isEnabled "BLK_DEV_INITRD")
        ]
      '';

      internal = true;
      type = types.listOf types.attrs;
    };

  };

  ###### implementation

  config = mkMerge [
    (mkIf config.boot.initrd.enable {
      boot.initrd.availableKernelModules = optionals config.boot.initrd.includeDefaultModules (
        [
          # Note: most of these (especially the SATA/PATA modules)
          # shouldn't be included by default since nixos-generate-config
          # detects them, but I'm keeping them for now for backwards
          # compatibility.

          # Some SATA/PATA stuff.
          "ahci"
          "sata_nv"
          "sata_via"
          "sata_sis"
          "sata_uli"
          "ata_piix"
          "pata_marvell"

          # NVMe
          "nvme"

          # Standard SCSI stuff.
          "sd_mod"
          "sr_mod"

          # SD cards and internal eMMC drives.
          "mmc_block"

          # Support USB keyboards, in case the boot fails and we only have
          # a USB keyboard, or for LUKS passphrase prompt.
          "uhci_hcd"
          "ehci_hcd"
          "ehci_pci"
          "ohci_hcd"
          "ohci_pci"
          "xhci_hcd"
          "xhci_pci"
          "usbhid"
          "hid_generic"
          "hid_lenovo"
          "hid_apple"
          "hid_roccat"
          "hid_logitech_hidpp"
          "hid_logitech_dj"
          "hid_microsoft"
          "hid_cherry"
          "hid_corsair"

        ]
        ++ optionals pkgs.stdenv.hostPlatform.isx86 [
          # Misc. x86 keyboard stuff.
          "pcips2"
          "atkbd"
          "i8042"
        ]
      );

      boot.initrd.kernelModules = optionals config.boot.initrd.includeDefaultModules [
        # For LVM.
        "dm_mod"
      ];
    })

    (mkIf config.boot.kernel.enable {
      # nixpkgs kernels are assumed to have all required features
      assertions =
        if config.boot.kernelPackages.kernel ? features then
          [ ]
        else
          let
            cfg = config.boot.kernelPackages.kernel.config;
          in
          map (attrs: {
            inherit (attrs) message;
            assertion = attrs.assertion cfg;
          }) config.system.requiredKernelConfig;

      boot.kernel.sysctl."kernel.printk" = mkDefault config.boot.consoleLogLevel;

      boot.kernelModules = [
        "loop"
        "atkbd"
      ];

      # Implement consoleLogLevel both in early boot and using sysctl
      # (so you don't need to reboot to have changes take effect).
      boot.kernelParams = [
        "loglevel=${toString config.boot.consoleLogLevel}"
      ];

      # Create /etc/modules-load.d/nixos.conf, which is read by
      # systemd-modules-load.service to load required kernel modules.
      environment.etc = {
        "modules-load.d/nixos.conf".source = kernelModulesConf;
      };

      lib.kernelConfig = {
        # True if no or omitted
        isDisabled = option: {
          assertion = config: config.isDisabled option;
          configLine = "CONFIG_${option}=n";
          message = "CONFIG_${option} is not disabled!";
        };

        ### Usually you will just want to use these two
        # True if yes or module
        isEnabled = option: {
          assertion = config: config.isEnabled option;
          configLine = "CONFIG_${option}=y";
          message = "CONFIG_${option} is not enabled!";
        };

        isModule = option: {
          assertion = config: config.isModule option;
          configLine = "CONFIG_${option}=m";
          message = "CONFIG_${option} is not built as a module!";
        };

        isNo = option: {
          assertion = config: config.isNo option;
          configLine = "CONFIG_${option}=n";
          message = "CONFIG_${option} is not no!";
        };

        isYes = option: {
          assertion = config: config.isYes option;
          configLine = "CONFIG_${option}=y";
          message = "CONFIG_${option} is not yes!";
        };
      };

      system.build = { inherit kernel; };
      system.modulesTree = [ (lib.getOutput "modules" kernel) ] ++ config.boot.extraModulePackages;

      # The config options that all modules can depend upon
      system.requiredKernelConfig =
        with config.lib.kernelConfig;
        [
          # !!! Should this really be needed?
          (isYes "BINFMT_ELF")
        ]
        ++ (optional (randstructSeed != "") (isYes "GCC_PLUGIN_RANDSTRUCT"));

      # Not required for, e.g., containers as they don't have their own kernel or initrd.
      # They boot directly into stage 2.
      system.systemBuilderArgs.kernelParams = config.boot.kernelParams;

      system.systemBuilderCommands =
        let
          kernelPath = "${config.boot.kernelPackages.kernel}/" + "${config.system.boot.loader.kernelFile}";
          initrdPath = "${config.system.build.initialRamdisk}/" + "${config.system.boot.loader.initrdFile}";
        in
        ''
          if [ ! -f ${kernelPath} ]; then
            echo "The bootloader cannot find the proper kernel image."
            echo "(Expecting ${kernelPath})"
            false
          fi

          ln -s ${kernelPath} $out/kernel
          ln -s ${config.system.modulesTree} $out/kernel-modules
          ${optionalString (config.hardware.deviceTree.package != null) ''
            ln -s ${config.hardware.deviceTree.package} $out/dtbs
          ''}

          echo -n "''${kernelParams[@]}" > $out/kernel-params

          ${optionalString config.boot.initrd.enable ''
            ln -s ${initrdPath} $out/initrd
          ''}

          ${optionalString (config.boot.initrd.secrets != { }) ''
            ln -s ${config.system.build.initialRamdiskSecretAppender}/bin/append-initrd-secrets $out
          ''}

          ln -s ${config.hardware.firmware}/lib/firmware $out/firmware
        '';

      systemd.services.systemd-modules-load = {
        restartTriggers = [ kernelModulesConf ];

        serviceConfig = {
          # Ignore failed module loads.  Typically some of the
          # modules in ‘boot.kernelModules’ are "nice to have but
          # not required" (e.g. acpi-cpufreq), so we don't want to
          # barf on those.
          SuccessExitStatus = "0 1";
        };

        wantedBy = [ "multi-user.target" ];
      };

    })

  ];

}
