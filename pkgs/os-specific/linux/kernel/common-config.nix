# WARNING/NOTE: whenever you want to add an option here you need to either
# * mark it as an optional one with `option`,
# * or make sure it works for all the versions in nixpkgs,
# * or check for which kernel versions it will work (using kernel
#   changelog, google or whatever) and mark it with `whenOlder` or
#   `whenAtLeast`.
# Then do test your change by building all the kernels (or at least
# their configs) in Nixpkgs or else you will guarantee lots and lots
# of pain to users trying to switch to an older kernel because of some
# hardware problems with a new one.

# Configuration
{
  lib,
  stdenv,
  rustAvailable,
  version,
  features ? { },
}:

with lib.kernel;
with (lib.kernel.whenHelpers version);

let
  # configuration items have to be part of a subattrs
  flattenKConf =
    nested:
    lib.mapAttrs (
      name: values:
      if lib.length values == 1 then
        lib.head values
      else
        throw "duplicate kernel configuration option: ${name}"
    ) (lib.zipAttrs (lib.attrValues nested));

  whenPlatformHasEBPFJit = lib.mkIf (
    stdenv.hostPlatform.isAarch32
    || stdenv.hostPlatform.isAarch64
    || stdenv.hostPlatform.isx86
    || (stdenv.hostPlatform.isPower && stdenv.hostPlatform.is64bit)
    || (stdenv.hostPlatform.isMips && stdenv.hostPlatform.is64bit)
  );

  forceRust = features.rust or false;
  # Architecture support collected from HAVE_RUST Kconfig definitions and the following table:
  # https://web.git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/rust/arch-support.rst
  rustByDefault = (
    lib.versionAtLeast version "6.12"
    && (
      stdenv.hostPlatform.isx86_64
      || stdenv.hostPlatform.isLoongArch64
      || stdenv.hostPlatform.isAarch64
      || (stdenv.hostPlatform.isRiscV64 && !stdenv.cc.isGNU)
    )
  );

  withRust =
    lib.warnIfNot (forceRust -> rustAvailable)
      "force-enabling Rust for Linux without an available rustc"
      lib.warnIfNot
      (forceRust -> rustByDefault)
      "force-enabling Rust for Linux on an unsupported kernel version, host platform or compiler"
      (forceRust || (rustAvailable && rustByDefault));

  options = {

    "9p" = {
      # Enable the 9P cache to speed up NixOS VM tests.
      "9P_FSCACHE" = option yes;
      "9P_FS_POSIX_ACL" = option yes;
    };

    accel = {
      # Build DRM accelerator devices
      DRM_ACCEL = whenAtLeast "6.2" yes;
    };

    brcmfmac = {
      BRCMFMAC_PCIE = option yes;
      # Enable PCIe and USB for the brcmfmac driver
      BRCMFMAC_USB = option yes;
    };

    container = {
      BLK_DEV_THROTTLING = yes;
      CFQ_GROUP_IOSCHED = whenOlder "5.0" yes; # Removed in 5.0-RC1
      CGROUP_DEVICE = yes;
      CGROUP_DMEM = whenAtLeast "6.14" yes;
      CGROUP_HUGETLB = yes;
      CGROUP_PERF = yes;
      CGROUP_PIDS = yes;
      CGROUP_RDMA = yes;
      MEMCG = yes;
      MEMCG_SWAP = whenOlder "6.1" yes;
      NAMESPACES = yes; # Required by 'unshare' used by 'nixos-install'
      RT_GROUP_SCHED = no;
    };

    criu = {
      # Unconditionally enabled, because it is required for CRIU and
      # it provides the kcmp() system call that Mesa depends on.
      CHECKPOINT_RESTORE = yes;
      # Allows soft-dirty tracking on pages, used by CRIU.
      # See https://docs.kernel.org/admin-guide/mm/soft-dirty.html
      MEM_SOFT_DIRTY = lib.mkIf (with stdenv.hostPlatform; isS390 || isPower64 || isx86_64) yes;
    };

    debug = {
      BPF_LSM = option yes;
      CRASH_DUMP = yes;
      DEBUG_DEVRES = no;
      # Necessary for BTF and crashkernel
      DEBUG_INFO = yes;
      # Intermittently breaks on 5.10 for unknown reasons.
      # https://lore.kernel.org/r/6dd6eef7-15cb-00a3-c216-d6eaaa5cbf54@est.tech
      DEBUG_INFO_BTF = whenAtLeast "5.11" (option yes);
      DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT = whenAtLeast "5.18" yes;
      # Reduced debug info conflict with BTF and have been enabled in
      # aarch64 defconfig since 5.13
      DEBUG_INFO_REDUCED = whenAtLeast "5.13" (option no);
      DEBUG_KERNEL = yes;
      DEBUG_STACK_USAGE = no;
      DETECT_HUNG_TASK = yes;
      DYNAMIC_DEBUG = yes;

      HARDLOCKUP_DETECTOR = lib.mkIf (
        with stdenv.hostPlatform; isPower || isx86 || lib.versionAtLeast version "6.5"
      ) yes;

      HIGHMEM4G = lib.mkIf (stdenv.hostPlatform.isx86 && stdenv.hostPlatform.is32bit) (
        whenAtLeast "6.15" yes
      );

      # Count IRQ and steal CPU time separately
      IRQ_TIME_ACCOUNTING = yes;
      # Enable CPU lockup detection
      LOCKUP_DETECTOR = yes;
      # Track memory leaks and performance issues related to allocations.
      MEM_ALLOC_PROFILING = whenAtLeast "6.10" yes;
      MEM_ALLOC_PROFILING_ENABLED_BY_DEFAULT = whenAtLeast "6.10" yes;
      # Allow loading modules with mismatched BTFs
      # FIXME: figure out how to actually make BTFs reproducible instead
      # See https://github.com/NixOS/nixpkgs/pull/181456 for details.
      MODULE_ALLOW_BTF_MISMATCH = whenAtLeast "5.18" (option yes);
      # Enable streaming logs to a remote device over a network
      NETCONSOLE = module;
      NETCONSOLE_DYNAMIC = yes;
      PARAVIRT_TIME_ACCOUNTING = yes;
      # Export known printks in debugfs
      PRINTK_INDEX = whenAtLeast "5.15" yes;
      # Enable crashkernel support
      PROC_VMCORE = yes;
      RCU_TORTURE_TEST = no;
      SCHEDSTATS = yes;
      # Provide access to tunables like sched_migration_cost_ns
      SCHED_DEBUG = whenOlder "6.15" yes;
      SOFTLOCKUP_DETECTOR = yes;
      # Easier debugging of NFS issues.
      SUNRPC_DEBUG = yes;
    };

    external-firmware = {
      # Support drivers that need external firmware.
      STANDALONE = no;
    };

    fb = {
      DRM_FBDEV_EMULATION = yes;
      FB = yes;
      FB_3DFX_ACCEL = yes;
      FB_ATY_CT = yes; # Mach64 CT/VT/GT/LT (incl. 3D RAGE) support
      FB_ATY_GX = yes; # Mach64 GX support
      FB_EFI = yes;
      FB_GEODE = lib.mkIf (stdenv.hostPlatform.system == "i686-linux") yes;
      FB_NVIDIA_I2C = yes; # Enable DDC Support
      FB_RIVA_I2C = yes;
      FB_SAVAGE_ACCEL = yes;
      FB_SAVAGE_I2C = yes;
      # Use simplefb on older kernels where we don't have simpledrm (enabled below)
      FB_SIMPLE = whenOlder "5.15" yes;
      FB_SIS_300 = yes;
      FB_SIS_315 = yes;
      FB_VESA = lib.mkIf stdenv.hostPlatform.isx86 yes;
      FRAMEBUFFER_CONSOLE = yes;
      FRAMEBUFFER_CONSOLE_DEFERRED_TAKEOVER = yes;
      FRAMEBUFFER_CONSOLE_DETECT_PRIMARY = yes;
      FRAMEBUFFER_CONSOLE_ROTATION = yes;
    };

    # Filesystem options - in particular, enable extended attributes and
    # ACLs for all filesystems that support them.
    filesystem = {
      # Provided by external module
      BCACHEFS_FS = whenBetween "6.7" "6.18" no;
      BTRFS_FS_POSIX_ACL = yes;
      CEPH_FSCACHE = yes;
      CEPH_FS_POSIX_ACL = yes;
      CIFS_DFS_UPCALL = yes;
      CIFS_FSCACHE = yes;
      CIFS_POSIX = option yes;
      CIFS_UPCALL = yes;
      CIFS_WEAK_PW_HASH = whenOlder "5.15" yes;
      CIFS_XATTR = yes;
      DEVTMPFS = yes;
      EROFS_FS_ZIP_DEFLATE = whenAtLeast "6.6" yes;
      EROFS_FS_ZIP_ZSTD = whenAtLeast "6.10" yes;
      EXT2_FS_POSIX_ACL = yes;
      EXT2_FS_SECURITY = yes;
      EXT2_FS_XATTR = yes;
      EXT3_FS_POSIX_ACL = option yes;
      EXT3_FS_SECURITY = option yes;
      EXT4_FS_POSIX_ACL = yes;
      EXT4_FS_SECURITY = yes;
      F2FS_FS = module;
      F2FS_FS_COMPRESSION = yes;
      F2FS_FS_SECURITY = option yes;
      FANOTIFY = yes;
      FANOTIFY_ACCESS_PERMISSIONS = yes;
      # DAX requires 64BIT via ZONE_DEVICE and MEMORY_HOTPLUG.
      FS_DAX = lib.mkIf stdenv.hostPlatform.is64bit yes;
      FS_ENCRYPTION = yes;
      FS_VERITY = yes;
      FS_VERITY_BUILTIN_SIGNATURES = yes;
      # Needed to use the installation iso image. Not included in all defconfigs (e.g. arm64)
      ISO9660_FS = module;
      JFS_POSIX_ACL = option yes;
      JFS_SECURITY = option yes;
      NFSD_V3_ACL = yes;
      NFSD_V4 = yes;
      NFSD_V4_SECURITY_LABEL = yes;
      NFS_FS = module;
      NFS_FSCACHE = yes;
      NFS_LOCALIO = whenAtLeast "6.12" yes;
      NFS_SWAP = yes;
      NFS_V3_ACL = yes;
      # NFSv4.1 is enabled unconditionally on 7.0 and up
      # see: https://github.com/torvalds/linux/commit/7537db24806fdc3d3ec4fef53babdc22c9219e75
      NFS_V4_1 = whenOlder "7.0" yes;
      NFS_V4_2 = yes;
      NFS_V4_SECURITY_LABEL = yes;
      # Native Language Support modules, needed by some filesystems
      NLS = yes;
      NLS_CODEPAGE_437 = module; # VFAT default for the codepage= mount option
      NLS_DEFAULT = freeform "utf8";
      NLS_ISO8859_1 = module; # VFAT default for the iocharset= mount option
      NLS_UTF8 = module;
      NTFS3_FS_POSIX_ACL = whenAtLeast "5.15" yes;
      NTFS3_LZX_XPRESS = whenAtLeast "5.15" yes;
      NTFS_FS = whenBetween "5.15" "6.9" no;
      NTFS_FS_POSIX_ACL = whenAtLeast "7.1" yes;
      OCFS2_DEBUG_MASKLOG = option no;
      REISERFS_FS_POSIX_ACL = whenOlder "6.13" (option yes);
      REISERFS_FS_SECURITY = whenOlder "6.13" (option yes);
      REISERFS_FS_XATTR = whenOlder "6.13" (option yes);
      SQUASHFS_CHOICE_DECOMP_BY_MOUNT = whenAtLeast "6.2" yes;
      SQUASHFS_DECOMP_MULTI_PERCPU = whenOlder "6.2" yes;
      SQUASHFS_FILE_DIRECT = yes;
      SQUASHFS_LZ4 = yes;
      SQUASHFS_LZO = yes;
      SQUASHFS_XATTR = yes;
      SQUASHFS_XZ = yes;
      SQUASHFS_ZLIB = yes;
      SQUASHFS_ZSTD = yes;
      TMPFS = yes;
      TMPFS_POSIX_ACL = yes;
      UBIFS_FS_ADVANCED_COMPR = option yes;
      UDF_FS = module;
      UNICODE = yes; # Casefolding support for filesystems
      XFS_ONLINE_SCRUB = option yes;
      XFS_POSIX_ACL = option yes;
      XFS_QUOTA = option yes;
      XFS_RT = option yes; # XFS Realtime subvolume support
    }
    // lib.optionalAttrs stdenv.hostPlatform.isPower {
      # Needed to use the installation iso image formatted for tbxi booting (ISO9660 w/ hybrid HFS+ partition).
      HFSPLUS_FS = yes;
    };

    fonts = {
      FONTS = yes;
      FONT_8x16 = yes;
      # Default fonts enabled if FONTS is not set
      FONT_8x8 = yes;
      # High DPI font
      FONT_TER16x32 = yes;
    };

    huge-page = {
      TRANSPARENT_HUGEPAGE = option yes;
      TRANSPARENT_HUGEPAGE_ALWAYS = option no;
      TRANSPARENT_HUGEPAGE_MADVISE = option yes;
    };

    iommu = lib.optionalAttrs stdenv.hostPlatform.isAarch64 {
      ARM_SMMU_V3_SVA = whenAtLeast "5.9" yes;
    };

    media = {
      MEDIA_ANALOG_TV_SUPPORT = yes;
      MEDIA_CAMERA_SUPPORT = yes;
      MEDIA_CONTROLLER = yes;
      MEDIA_DIGITAL_TV_SUPPORT = yes;
      MEDIA_PCI_SUPPORT = yes;
      MEDIA_USB_SUPPORT = yes;
      VIDEO_STK1160_COMMON = whenOlder "6.5" module;
    };

    memory = {
      DAMON = whenAtLeast "5.15" yes;
      DAMON_DBGFS = whenBetween "5.15" "6.9" yes;
      DAMON_LRU_SORT = whenAtLeast "6.0" yes;
      DAMON_PADDR = whenAtLeast "5.16" yes;
      DAMON_RECLAIM = whenAtLeast "5.16" yes;
      DAMON_STAT = whenAtLeast "6.17" yes;
      DAMON_SYSFS = whenAtLeast "5.18" yes;
      DAMON_VADDR = whenAtLeast "5.15" yes;
      # Support recovering from memory failures on systems with ECC and MCA recovery.
      MEMORY_FAILURE = yes;
      # Collect ECC errors and retire pages that fail too often
      RAS_CEC = lib.mkIf stdenv.hostPlatform.isx86 yes;
    }
    // lib.optionalAttrs (stdenv.hostPlatform.is32bit) {
      BOUNCE = option yes;
      # Enable access to the full memory range (aka PAE) on 32-bit architectures
      # This check isn't super accurate but it's close enough
      HIGHMEM = option yes;
    };

    memtest = {
      MEMTEST = yes;
    };

    microcode = {
      # Write Back Throttling
      # https://lwn.net/Articles/682582/
      # https://bugzilla.kernel.org/show_bug.cgi?id=12309#c655
      BLK_WBT = yes;
      BLK_WBT_MQ = yes;
      BLK_WBT_SQ = whenOlder "5.0" yes; # Removed in 5.0-RC1
      MICROCODE = lib.mkIf stdenv.hostPlatform.isx86 yes;
      MICROCODE_AMD = lib.mkIf stdenv.hostPlatform.isx86 (whenOlder "6.6" yes);
      MICROCODE_INTEL = lib.mkIf stdenv.hostPlatform.isx86 (whenOlder "6.6" yes);
    };

    misc =
      let
        # Use zstd for kernel compression if 64-bit and newer than 5.9, otherwise xz.
        # i686 issues: https://github.com/NixOS/nixpkgs/pull/117961#issuecomment-812106375
        useZstd = stdenv.buildPlatform.is64bit;
      in
      {
        "8139TOO_8129" = yes;
        "8139TOO_PIO" = no; # PIO is slower
        ACCESSIBILITY = yes; # Accessibility support
        ACPI_APEI_PCIEAER = yes;
        AIC79XX_DEBUG_ENABLE = no;
        AIC7XXX_DEBUG_ENABLE = no;
        AIC94XX_DEBUG = no;
        AIO = yes; # POSIX asynchronous I/O

        ANDROID = {
          optional = true;
          tristate = whenBetween "5.0" "5.19" "y";
        };

        ANDROID_BINDERFS = {
          optional = true;
          tristate = "y";
        };

        ANDROID_BINDER_DEVICES = {
          freeform = "binder,hwbinder,vndbinder";
          optional = true;
        };

        ANDROID_BINDER_IPC = {
          optional = true;
          tristate = "y";
        };

        ARM64_PMEM = lib.mkIf stdenv.hostPlatform.isAarch64 yes;

        ASHMEM = {
          optional = true;
          tristate = whenBetween "5.0" "5.18" "y";
        };

        # Disabled by default on POWER
        ATA_BMDMA = yes;
        ATA_SFF = yes;
        AUXDISPLAY = yes; # Auxiliary Display support
        # For systemd-binfmt
        BINFMT_MISC = option yes;
        # Our initrd init uses shebang scripts, so can't be modular.
        BINFMT_SCRIPT = yes;
        # Enable initrd support.
        BLK_DEV_INITRD = yes;
        BLK_DEV_INTEGRITY = yes;
        BLK_DEV_ZONED = yes;
        # Enable support for block layer inline encryption
        BLK_INLINE_ENCRYPTION = yes;
        # ...but fall back to CPU encryption if unavailable
        BLK_INLINE_ENCRYPTION_FALLBACK = yes;
        BLK_SED_OPAL = yes;
        BSD_PROCESS_ACCT_V3 = yes;
        BT_HCIBTUSB_MTK = yes; # MediaTek protocol support
        BT_HCIUART = module; # required for BT devices with serial port interface (QCA6390)
        BT_HCIUART_BCM = option yes; # Broadcom Bluetooth support
        BT_HCIUART_BCSP = option yes; # CSR BlueCore support
        BT_HCIUART_H4 = option yes; # UART (H4) protocol support
        BT_HCIUART_LL = option yes; # Texas Instruments BRF
        BT_HCIUART_QCA = yes; # Qualcomm Atheros support
        BT_HCIUART_SERDEV = yes; # required by BT_HCIUART_QCA
        BT_QCA = module; # enables QCA6390 bluetooth
        BT_RFCOMM_TTY = option yes; # RFCOMM TTY support
        CFS_BANDWIDTH = yes;
        CGROUPS = yes; # used by systemd
        # Removed on 5.17 as it was unused
        # upstream: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=0a4ee518185e902758191d968600399f3bc2be31
        CLEANCACHE = whenOlder "5.17" (option yes);
        DEVFREQ_THERMAL = yes;
        # required for P2P DMABUF
        DMABUF_MOVE_NOTIFY = lib.mkIf stdenv.hostPlatform.is64bit (whenBetween "6.6" "7.1" yes);
        DRAGONRISE_FF = yes;
        DRM_AMDGPU_USERPTR = yes;
        DVB_DYNAMIC_MINORS = option yes; # we use udev
        EFI = lib.mkIf stdenv.hostPlatform.isEfi yes;
        EFI_GENERIC_STUB_INITRD_CMDLINE_LOADER = whenOlder "6.2" yes; # initrd kernel parameter for EFI
        EFI_STUB = yes; # EFI bootloader in the bzImage itself
        EFI_VARS_PSTORE = lib.mkIf (!stdenv.hostPlatform.isLoongArch64) yes;
        # Generic compression support for EFI payloads
        # Add new platforms only after they have been verified to build and boot.
        # This is unsupported on x86 due to a custom decompression mechanism.
        EFI_ZBOOT = lib.mkIf stdenv.hostPlatform.isAarch64 (whenAtLeast "6.1" yes);
        FHANDLE = yes; # used by systemd
        FRONTSWAP = whenOlder "6.6" yes;
        FSCACHE_STATS = yes;

        FSL_MC_UAPI_SUPPORT = lib.mkIf (stdenv.hostPlatform.system == "aarch64-linux") (
          whenAtLeast "5.12" yes
        );

        FUSION = yes; # Fusion MPT device support
        # Required for EDID overriding
        FW_LOADER = yes;
        FW_LOADER_COMPRESS = yes;
        FW_LOADER_COMPRESS_ZSTD = whenAtLeast "5.19" yes;
        # Disable the firmware helper fallback, udev doesn't implement it any more
        FW_LOADER_USER_HELPER_FALLBACK = option no;
        # Enable coreboot firmware drivers.
        # While these are called CONFIG_GOOGLE_*, they apply to coreboot systems in general.
        GOOGLE_FIRMWARE = yes;
        GREENASIA_FF = yes;
        # enabled by default in x86_64 but not arm64, so we do that here
        HIDRAW = yes;
        HID_ACRUX_FF = yes;
        HID_BATTERY_STRENGTH = yes;
        # Enable loading HID fixups as eBPF from userspace
        HID_BPF = whenAtLeast "6.3" (whenPlatformHasEBPFJit yes);
        # 6.18-rc1 fails to link otherwise, at least on aarch64
        HID_HAPTIC = whenAtLeast "6.18" yes;
        HIPPI = whenOlder "7.0" yes;
        HMM_MIRROR = yes;
        HOLTEK_FF = yes;
        HOTPLUG_PCI_ACPI = yes; # PCI hotplug using ACPI
        HOTPLUG_PCI_PCIE = yes; # PCI-Expresscard hotplug support
        # Enable AMD's ROCm GPU compute stack
        HSA_AMD = lib.mkIf stdenv.hostPlatform.is64bit yes;
        # required for P2P transfers between accelerators
        HSA_AMD_P2P = lib.mkIf stdenv.hostPlatform.is64bit (whenAtLeast "6.6" yes);
        HWMON = yes;

        IDE = lib.mkIf (with stdenv.hostPlatform; isAarch32 || isM68k || isMips || isPower || isx86) (
          whenOlder "5.14" no
        ); # deprecated IDE support, removed in 5.14

        IDLE_PAGE_TRACKING = yes;
        INPUT_JOYSTICK = yes;
        JOYSTICK_PSXPAD_SPI_FF = yes;
        JOYSTICK_XPAD_FF = option yes; # X-Box gamepad rumble support
        JOYSTICK_XPAD_LEDS = option yes; # LED Support for Xbox360 controller 'BigX' LED
        # The default target assumes uncompressed on RISC-V.
        KERNEL_UNCOMPRESSED = lib.mkIf stdenv.hostPlatform.isRiscV yes;

        KERNEL_XZ = lib.mkIf (
          with stdenv.hostPlatform; (isAarch32 || isMips || isPower || isS390 || isx86) && !useZstd
        ) yes;

        KERNEL_ZSTD = lib.mkIf (
          with stdenv.hostPlatform;
          (isMips || isS390 || isx86 || (lib.versionAtLeast version "6.1" && isAarch64 || isLoongArch64))
          && useZstd
        ) yes;

        KEXEC_FILE = option yes;
        KEXEC_HANDOVER = whenAtLeast "6.16" (option yes);
        KEXEC_JUMP = option yes;
        KEYBOARD_APPLESPI = lib.mkIf stdenv.hostPlatform.isx86 module;
        # > CONFIG_KUNIT should not be enabled in a production environment. Enabling KUnit disables Kernel Address-Space Layout Randomization (KASLR), and tests may affect the state of the kernel in ways not suitable for production.
        # https://www.kernel.org/doc/html/latest/dev-tools/kunit/start.html
        KUNIT = no;
        # Windows Logical Disk Manager (Dynamic Disk) support
        LDM_PARTITION = yes;
        LEGACY_TIOCSTI = whenAtLeast "6.2" no;
        LIRC = yes;
        LIVEUPDATE = whenAtLeast "6.19" (option yes);
        LOGIG940_FF = yes;
        LOGIRUMBLEPAD2_FF = yes; # Logitech Rumblepad 2 force feedback
        LOGITECH_FF = yes;
        LOGIWHEELS_FF = yes;
        LOGO = no; # not needed
        LRU_GEN = whenAtLeast "6.1" yes;
        LRU_GEN_ENABLED = whenAtLeast "6.1" yes;
        MD = yes; # Device mapper (RAID, LVM, etc.)
        MEDIA_ATTACH = yes;
        MEGARAID_NEWGEN = yes;
        MLX5_CORE_EN = option yes;
        # 8 is default. Modern gpt tables on eMMC may go far beyond 8.
        MMC_BLOCK_MINORS = freeform "32";

        MODULE_COMPRESS = lib.mkMerge [
          (whenOlder "5.13" yes)
          (whenAtLeast "6.12" yes)
        ];

        MODULE_COMPRESS_ALL = whenAtLeast "6.12" yes;
        MODULE_COMPRESS_XZ = yes;
        MOUSE_ELAN_I2C_SMBUS = yes;
        MOUSE_PS2_ELANTECH = yes; # Elantech PS/2 protocol extension
        MOUSE_PS2_VMMOUSE = lib.mkIf stdenv.hostPlatform.isx86 yes;
        MTD_COMPLEX_MAPPINGS = yes; # needed for many devices
        MTRR_SANITIZER = lib.mkIf stdenv.hostPlatform.isx86 yes;
        NET_FC = yes; # Fibre Channel driver support
        NINTENDO_FF = whenAtLeast "5.16" yes;
        NVIDIA_SHIELD_FF = whenAtLeast "6.5" yes;

        NVME_AUTH = lib.mkMerge [
          (whenBetween "6.0" "6.7" yes)
          (whenAtLeast "6.7" module)
        ];

        NVME_HOST_AUTH = whenAtLeast "6.7" yes;
        NVME_HWMON = yes; # NVMe drives temperature reporting
        NVME_MULTIPATH = yes;
        NVME_TARGET = module;
        NVME_TARGET_AUTH = whenAtLeast "6.0" yes;
        NVME_TARGET_PASSTHRU = yes;
        NVME_TARGET_TCP_TLS = whenAtLeast "6.7" yes;
        NVME_TCP_TLS = whenAtLeast "6.7" yes;
        # enable support for device trees and overlays
        OF = option yes;

        # OF_OVERLAY breaks v5.10 on x86_64, see https://github.com/NixOS/nixpkgs/issues/403985
        OF_OVERLAY = lib.mkIf (!(lib.versionOlder version "5.15" && stdenv.hostPlatform.isx86_64)) (
          option yes
        );

        PARTITION_ADVANCED = yes; # Needed for LDM_PARTITION
        # Allos PCIe devices report errors with Advanced Error Reporting (AER).
        PCIEAER = yes;

        PCI_P2PDMA = lib.mkIf (
          with stdenv.hostPlatform;
          isLoongArch64
          || isPower64
          || isS390x
          || isx86_64
          || isAarch64
          || (lib.versionAtLeast version "6.11" && isRiscV64)
        ) yes;

        # Needed for touchpads to work on some AMD laptops
        PINCTRL_AMD = whenAtLeast "5.19" yes;
        # GPIO on Intel Bay Trail, for some Chromebook internal eMMC disks
        PINCTRL_BAYTRAIL = lib.mkIf stdenv.hostPlatform.isx86 yes;
        # GPIO for Braswell and Cherryview devices
        # Needs to be built-in to for integrated keyboards to function properly
        PINCTRL_CHERRYVIEW = lib.mkIf stdenv.hostPlatform.isx86 yes;
        PLAYSTATION_FF = whenAtLeast "5.12" yes;
        # Allows debugging systems that get stuck during suspend/resume
        PM_TRACE_RTC = lib.mkIf stdenv.hostPlatform.isx86 yes;
        POSIX_MQUEUE = yes;
        # We want to prefer PREEMPT_LAZY when available, and fall back on PREEMPT_VOLUNTARY.
        # The version cutoff is arbitrary, the real cutoff is somewhere around 6.13 depending on target.
        PREEMPT = no;
        PREEMPT_LAZY = whenAtLeast "6.18" yes;
        PREEMPT_VOLUNTARY = whenOlder "6.18" yes;
        PSI = yes;
        PSTORE = yes;
        RAS = yes; # Needed for EDAC support
        RC_DECODERS = option yes; # Required for IR devices to work
        RC_DEVICES = option yes; # Enable IR devices
        REGULATOR = yes; # Voltage and Current Regulator Support
        RT2800USB_RT53XX = yes;
        RT2800USB_RT55XX = yes;
        # Set system time from RTC on startup and resume
        RTC_HCTOSYS = option yes;
        SCHED_AUTOGROUP = yes;
        SCHED_CLASS_EXT = whenAtLeast "6.12" (whenPlatformHasEBPFJit yes);
        SCHED_CORE = whenAtLeast "5.14" yes;
        SCSI_LOGGING = yes; # SCSI logging facility
        SCSI_LOWLEVEL = yes; # enable lots of SCSI devices
        SCSI_LOWLEVEL_PCMCIA = yes;
        SCSI_SAS_ATA = yes; # added to enable detection of hard drive
        SECCOMP = yes; # used by systemd >= 231
        SECCOMP_FILTER = yes; # ditto
        SERIAL_8250 = yes; # 8250/16550 and compatible serial support
        SERIAL_DEV_BUS = yes; # enables support for serial devices
        SERIAL_DEV_CTRL_TTYPORT = yes; # enables support for TTY serial devices
        SLAB_FREELIST_HARDENED = yes;
        SLAB_FREELIST_RANDOM = yes;
        SLIP_COMPRESSED = yes; # CSLIP compressed headers
        SLIP_SMART = yes;
        SMARTJOYPLUS_FF = yes;
        SONY_FF = yes;
        SPI = yes; # needed for many devices
        SPI_MASTER = yes;
        SYSVIPC = yes; # System-V IPC
        TASKSTATS = yes;
        TASK_DELAY_ACCT = yes;
        TASK_IO_ACCOUNTING = yes;
        TASK_XACCT = yes;
        # Enable all available thermal governors
        THERMAL_GOV_BANG_BANG = yes;
        THERMAL_GOV_FAIR_SHARE = yes;
        THERMAL_GOV_POWER_ALLOCATOR = yes;
        THERMAL_GOV_STEP_WISE = yes;
        THERMAL_GOV_USER_SPACE = yes;
        THERMAL_HWMON = yes; # Hardware monitoring support
        THRUSTMASTER_FF = yes;
        UEVENT_HELPER = no;
        UNIX = yes; # Unix domain sockets.
        USERFAULTFD = yes;
        # Expose watchdog information in sysfs
        WATCHDOG_SYSFS = yes;
        # Enable generic kernel watch queues
        # See https://docs.kernel.org/core-api/watch_queue.html
        WATCH_QUEUE = yes;
        # Fresh toolchains frequently break -Werror build for minor issues.
        WERROR = whenAtLeast "5.15" no;
        X86_AMD_PLATFORM_DEVICE = lib.mkIf stdenv.hostPlatform.isx86 yes;
        X86_CHECK_BIOS_CORRUPTION = lib.mkIf stdenv.hostPlatform.isx86 yes;
        X86_MCE = lib.mkIf stdenv.hostPlatform.isx86 yes;
        X86_PLATFORM_DRIVERS_DELL = lib.mkIf stdenv.hostPlatform.isx86 (whenAtLeast "5.12" yes);
        X86_PLATFORM_DRIVERS_HP = lib.mkIf stdenv.hostPlatform.isx86 (whenAtLeast "6.1" yes);
        ZEROPLUS_FF = yes;

        ZONE_DEVICE = lib.mkIf (
          with stdenv.hostPlatform;
          isLoongArch64
          || isPower64
          || isS390x
          || isx86_64
          || isAarch64
          || (lib.versionAtLeast version "6.11" && isRiscV64)
        ) yes;
      }
      //
        lib.optionalAttrs
          (stdenv.hostPlatform.system == "x86_64-linux" || stdenv.hostPlatform.system == "aarch64-linux")
          {
            # Enable CPU/memory hotplug support
            # Allows you to dynamically add & remove CPUs/memory to a VM client running NixOS without requiring a reboot
            ACPI_HOTPLUG_CPU = yes;
            ACPI_HOTPLUG_MEMORY = yes;
            CHROMEOS_TBMC = module;
            # Required for various hardware features on Chrome OS devices
            CHROME_PLATFORMS = yes;
            CROS_EC = module;
            CROS_EC_I2C = module;
            CROS_EC_SPI = module;
            CROS_KBD_LED_BACKLIGHT = module;
            HOTPLUG_CPU = yes;
            # Enable LEDS to display link-state status of PHY devices (i.e. eth lan/wan interfaces)
            LED_TRIGGER_PHY = yes;
            MEMORY_HOTPLUG = yes;
            MEMORY_HOTPLUG_DEFAULT_ONLINE = whenOlder "6.14" yes;

            MEMORY_HOTREMOVE = lib.mkIf (
              with stdenv.hostPlatform;
              isLoongArch64
              || isPower
              || isS390
              || isx86
              || isAarch64
              || (lib.versionAtLeast version "6.11" && isRiscV)
            ) yes;

            MHP_DEFAULT_ONLINE_TYPE_ONLINE_AUTO = whenAtLeast "6.14" yes;
            MIGRATION = yes;
            # Bump the maximum number of CPUs to support systems like EC2 x1.*
            # instances and Xeon Phi.
            NR_CPUS = freeform "384";
            SPARSEMEM = yes;
            TCG_TIS_SPI_CR50 = yes;
          }
      //
        lib.optionalAttrs
          (stdenv.hostPlatform.system == "armv7l-linux" || stdenv.hostPlatform.system == "aarch64-linux")
          {
            # https://docs.kernel.org/arch/arm/mem_alignment.html
            # tldr:
            #  when buggy userspace code emits illegal misaligned LDM, STM,
            #  LDRD and STRDs, the instructions trap, are caught, and then
            #  are emulated by the kernel.
            #
            #  This is the default on armv7l, anyway, but it is explicitly
            #  enabled here for the sake of providing context for the
            #  aarch64 compat option which follows.
            ALIGNMENT_TRAP = lib.mkIf (stdenv.hostPlatform.system == "armv7l-linux") yes;
            # requirement for CP15_BARRIER_EMULATION
            ARMV8_DEPRECATED = lib.mkIf (stdenv.hostPlatform.system == "aarch64-linux") yes;
            # Add debug interfaces for CMA
            CMA_DEBUGFS = yes;
            # Distros should configure the default as a kernel option.
            # We previously defined it on the kernel command line as cma=
            # The kernel command line will override a platform-specific configuration from its device tree.
            # https://github.com/torvalds/linux/blob/856deb866d16e29bd65952e0289066f6078af773/kernel/dma/contiguous.c#L35-L44
            CMA_SIZE_MBYTES = freeform "32";
            CMA_SYSFS = whenAtLeast "5.13" yes;

            # https://patchwork.kernel.org/project/linux-arm-kernel/patch/20220701135322.3025321-1-ardb@kernel.org/
            # tldr:
            #  when encountering alignment faults under aarch64, this option
            #  makes the kernel attempt to handle the fault by doing the
            #  same style of misaligned emulation that is performed under
            #  armv7l (see above option).
            #
            #  This minimizes the potential for aarch32 userspace to behave
            #  differently when run under aarch64 kernels compared to when
            #  it is run under an aarch32 kernel.
            COMPAT_ALIGNMENT_FIXUPS = lib.mkIf (stdenv.hostPlatform.system == "aarch64-linux") (
              whenAtLeast "6.1" yes
            );

            # emulate a specific armv7 instruction that was removed from armv8
            # this instruction is required to build a native armv7 nodejs on an
            # aarch64-linux builder, for example
            CP15_BARRIER_EMULATION = lib.mkIf (stdenv.hostPlatform.system == "aarch64-linux") yes;
            # See comments on https://github.com/NixOS/nixpkgs/commit/9b67ea9106102d882f53d62890468071900b9647
            CRYPTO_AEGIS128_SIMD = no;
            # Enables support for the Allwinner Display Engine 2.0
            SUN8I_DE2_CCU = yes;
          }
      // lib.optionalAttrs (stdenv.hostPlatform.system == "x86_64-linux") {
        # Enable AMD heterogeneous core hardware feedback interface
        AMD_HFI = whenAtLeast "6.17" yes;
        # Enable AMD Wi-Fi RF band mitigations
        # See https://cateee.net/lkddb/web-lkddb/AMD_WBRF.html
        AMD_WBRF = whenAtLeast "6.8" yes;
        CHROMEOS_LAPTOP = module;
        CHROMEOS_PSTORE = module;
        CROS_EC_ISHTP = module;
        CROS_EC_LPC = module;
        # Enable Intel Turbo Boost Max 3.0
        INTEL_TURBO_MAX_3 = yes;
        # Enable x86 resource control
        X86_CPU_RESCTRL = yes;
        # Enable TSX on CPUs where it's not vulnerable
        X86_INTEL_TSX_MODE_AUTO = yes;
      }
      // lib.optionalAttrs (stdenv.hostPlatform.isPower64) {
        # Does not get auto-loaded on relevant systems, makes fans stuck at max speed.
        # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=713943 (2014 :<)
        # > This module ought to be auto-loaded where it's needed, but somehow that
        # > has broken.  I asked Benjamin Herrenschmidt (upstream powerpc maintainer
        # > and the last person to touch it) and he was aware of this but hadn't got
        # > round to working out why.  The workaround is to build it in[…].
        # > (It won't do any harm on non-Mac systems.)
        I2C_POWERMAC = yes;
        PPC_4K_PAGES = yes;
        # avoid driver/FS trouble arising from unusual page size
        PPC_64K_PAGES = no;
      }
      // lib.optionalAttrs stdenv.hostPlatform.isPower {
        # Needed for booting PowerMacs from disc
        # (the only nice way that doesn't involve messing around with internal drives or in Open Firmware)
        ATA = yes;
        PATA_MACIO = yes;
      };

    networking = {
      AX25 = whenOlder "7.1" module;
      BONDING = module;
      BPF_JIT = whenPlatformHasEBPFJit yes;
      BPF_JIT_ALWAYS_ON = whenPlatformHasEBPFJit no; # whenPlatformHasEBPFJit yes; # see https://github.com/NixOS/nixpkgs/issues/79304
      BPF_STREAM_PARSER = yes;
      BRIDGE_VLAN_FILTERING = yes;
      # Enable debugfs for wireless drivers
      CFG80211_DEBUGFS = yes;
      # Required by systemd per-cgroup firewalling
      CGROUP_BPF = option yes;
      CGROUP_NET_PRIO = yes; # Required by systemd
      CLS_U32_MARK = yes;
      CLS_U32_PERF = yes;
      # HAM radio
      HAMRADIO = whenOlder "7.1" yes;
      HAVE_EBPF_JIT = whenPlatformHasEBPFJit yes;
      INET6_ESPINTCP = yes;
      # needed for ss
      # Use a lower priority to allow these options to be overridden in hardened/config.nix
      INET_DIAG = lib.mkDefault module;
      INET_DIAG_DESTROY = lib.mkDefault yes;
      # IPsec over TCP
      INET_ESPINTCP = yes;
      INET_MPTCP_DIAG = lib.mkDefault module;
      INET_RAW_DIAG = lib.mkDefault module;
      INET_TCP_DIAG = lib.mkDefault module;
      INET_UDP_DIAG = lib.mkDefault module;
      # infiniband
      INFINIBAND = module;
      INFINIBAND_IPOIB = module;
      INFINIBAND_IPOIB_CM = yes;
      IPV6 = yes;
      IPV6_MROUTE = yes;
      IPV6_MROUTE_MULTIPLE_TABLES = yes;
      IPV6_MULTIPLE_TABLES = yes;
      IPV6_OPTIMISTIC_DAD = yes;
      IPV6_PIMSM_V2 = yes;
      IPV6_ROUTER_PREF = yes;
      IPV6_ROUTE_INFO = yes;
      IPV6_SEG6_BPF = yes;
      IPV6_SEG6_HMAC = yes;
      IPV6_SEG6_LWTUNNEL = yes;
      IPV6_SUBTREES = yes;
      IP_ADVANCED_ROUTER = yes;
      IP_DCCP_CCID3 = whenOlder "6.16" no; # experimental
      IP_MROUTE = yes;
      IP_MROUTE_MULTIPLE_TABLES = yes;
      IP_MULTICAST = yes;
      IP_MULTIPLE_TABLES = yes;
      IP_NF_TARGET_REDIRECT = whenOlder "6.17" module;
      IP_PNP = no;
      IP_ROUTE_MULTIPATH = yes;
      IP_ROUTE_VERBOSE = yes;
      IP_VS_IPV6 = yes;
      IP_VS_PROTO_AH = yes;
      IP_VS_PROTO_ESP = yes;
      IP_VS_PROTO_TCP = yes;
      IP_VS_PROTO_UDP = yes;
      # needed for iwd WPS support (wpa_supplicant replacement)
      KEY_DH_OPERATIONS = yes;
      L2TP_ETH = module;
      L2TP_IP = module;
      L2TP_V3 = yes;
      MAC80211_DEBUGFS = yes;
      # enable multipath-tcp
      MPTCP = yes;
      MPTCP_IPV6 = yes;
      NET = yes;
      # needed for nftables
      # Networking Options
      NETFILTER = yes;
      NETFILTER_ADVANCED = yes;
      NETFILTER_NETLINK_GLUE_CT = yes;
      NETKIT = whenAtLeast "6.7" yes;
      NET_ACT_BPF = module;
      NET_CLS_ACT = yes;
      NET_CLS_BPF = module;
      # needed for `dropwatch`
      # Builtin-only since https://github.com/torvalds/linux/commit/f4b6bcc7002f0e3a3428bac33cf1945abff95450
      NET_DROP_MONITOR = yes;
      NET_FOU_IP_TUNNELS = option yes;
      NET_L3_MASTER_DEV = option yes;
      NET_SCHED = yes;
      NET_SCH_BPF = whenAtLeast "6.16" (whenPlatformHasEBPFJit yes);
      NFT_REJECT_NETDEV = whenAtLeast "5.11" module;
      NF_CONNTRACK_EVENTS = yes;
      # Expose some debug info
      NF_CONNTRACK_PROCFS = yes;
      NF_CONNTRACK_TIMEOUT = yes;
      NF_CONNTRACK_TIMESTAMP = yes;
      # Core Netfilter Configuration
      NF_CONNTRACK_ZONES = yes;
      NF_FLOW_TABLE_PROCFS = whenAtLeast "6.0" yes;
      NF_TABLES_ARP = yes;
      # Bridge Netfilter Configuration
      NF_TABLES_BRIDGE = module;
      NF_TABLES_INET = yes;
      # IP: Netfilter Configuration
      NF_TABLES_IPV4 = yes;
      # IPv6: Netfilter Configuration
      NF_TABLES_IPV6 = yes;
      NF_TABLES_NETDEV = yes;
      PPP_FILTER = yes;
      PPP_MULTILINK = yes; # PPP multilink support
      TCP_CONG_ADVANCED = yes;
      TCP_CONG_CUBIC = yes; # This is the default congestion control algorithm since 2.6.19
      # Kernel TLS
      TLS = module;
      TLS_DEVICE = yes;
      WAN = yes;
      XDP_SOCKETS = yes;
      XDP_SOCKETS_DIAG = yes;
    }
    // lib.optionalAttrs (stdenv.hostPlatform.system == "aarch64-linux") {
      # Enable SoC interface for MT7915 module, required for MT798X.
      MT7986_WMAC = whenBetween "5.18" "6.6" yes;
      MT798X_WMAC = whenAtLeast "6.6" yes;
      # Not enabled by default, hides modules behind it
      NET_VENDOR_MEDIATEK = yes;
    };

    # Enable NUMA.
    numa = {
      NUMA = option yes;
      NUMA_BALANCING = option yes;
    };

    optimization = {
      # Optimize with -O2, not -Os
      CC_OPTIMIZE_FOR_SIZE = no;
      X86_GENERIC = lib.mkIf (stdenv.hostPlatform.system == "i686-linux") yes;
    };

    perf = {
      # enable AMD Zen branch sampling if available
      PERF_EVENTS_AMD_BRS = whenAtLeast "5.19" (option yes);
    };

    power-management = {
      # ACPI Platform Error Interface
      ACPI_APEI = (option yes);
      # APEI Generic Hardware Error Source
      ACPI_APEI_GHES = (option yes);
      # Without this, on some hardware the kernel fails at some
      # point after the EFI stub has executed but before a console
      # is set up. Regardless, it's good to have the extra debug
      # anyway.
      ACPI_DEBUG = yes;
      # ACPI Firmware Performance Data Table Support
      ACPI_FPDT = whenAtLeast "5.12" (option yes);
      # ACPI Heterogeneous Memory Attribute Table Support
      ACPI_HMAT = option yes;
      # Auto suspend Bluetooth devices at idle
      BT_HCIBTUSB_AUTOSUSPEND = yes;
      CPU_FREQ_DEFAULT_GOV_SCHEDUTIL = yes;
      CPU_FREQ_GOV_SCHEDUTIL = yes;
      # Expose cpufreq stats in sysfs
      CPU_FREQ_STAT = yes;
      # Enable CPU energy model for scheduling
      ENERGY_MODEL = yes;
      PM_ADVANCED_DEBUG = yes;
      PM_DEBUG = yes;
      PM_WAKELOCKS = yes;
      POWERCAP = yes;
      # GPIO power management
      POWER_RESET_GPIO = option yes;
      POWER_RESET_GPIO_RESTART = option yes;
      # Enable Pulse-Width-Modulation support, commonly used for fan and backlight.
      PWM = yes;
      # Enable lazy RCUs for power savings:
      # https://lore.kernel.org/rcu/20221019225138.GA2499943@paulmck-ThinkPad-P17-Gen-1/
      # RCU_LAZY depends on RCU_NOCB_CPU depends on NO_HZ_FULL
      # depends on HAVE_VIRT_CPU_ACCOUNTING_GEN depends on 64BIT,
      # so we can't force-enable this
      RCU_LAZY = whenAtLeast "6.2" (option yes);
      # Default SATA link power management to "medium with device initiated PM"
      # for some extra power savings.
      SATA_MOBILE_LPM_POLICY = whenAtLeast "5.18" (freeform "3");
      # Enable thermal interface netlink API
      THERMAL_NETLINK = yes;
      # Prefer power-efficient workqueue implementation to per-CPU workqueues,
      # which is slightly slower, but improves battery life.
      # This is opt-in per workqueue, and can be disabled globally with a kernel command line option.
      WQ_POWER_EFFICIENT_DEFAULT = yes;
    }
    // lib.optionalAttrs (stdenv.hostPlatform.isx86) {
      # Intel DPTF (Dynamic Platform and Thermal Framework) Support
      ACPI_DPTF = yes;
      BXT_WC_PMIC_OPREGION = yes;
      BYTCRC_PMIC_OPREGION = yes;
      CHTCRC_PMIC_OPREGION = yes;
      CHT_DC_TI_PMIC_OPREGION = yes;
      CHT_WC_PMIC_OPREGION = yes;
      # Required to bring up some Bay Trail devices properly
      I2C = yes;
      I2C_DESIGNWARE_CORE = yes;
      I2C_DESIGNWARE_PLATFORM = yes;
      # Enable Intel thermal hardware feedback
      INTEL_HFI_THERMAL = whenAtLeast "5.18" yes;
      INTEL_IDLE = yes;
      INTEL_RAPL = module;
      INTEL_SOC_PMIC = yes;
      INTEL_SOC_PMIC_CHTDC_TI = yes;
      INTEL_SOC_PMIC_CHTWC = yes;
      MFD_TPS68470 = whenOlder "5.13" yes;
      PMIC_OPREGION = yes;
      TPS68470_PMIC_OPREGION = yes;
      X86_AMD_PSTATE = whenAtLeast "5.17" yes;
      X86_INTEL_LPSS = yes;
      X86_INTEL_PSTATE = yes;
      XPOWER_PMIC_OPREGION = yes;
    };

    proc-config-gz = {
      # Make /proc/config.gz available
      IKCONFIG = yes;
      IKCONFIG_PROC = yes;
    };

    proc-events = {
      # PROC_EVENTS requires that the netlink connector is not built
      # as a module.  This is required by libcgroup's cgrulesengd.
      CONNECTOR = yes;
      PROC_EVENTS = yes;
    };

    # Enable Rust and features that depend on it
    # Use a lower priority to allow these options to be overridden in hardened/config.nix
    rust = lib.optionalAttrs withRust {
      DRM_NOVA = whenAtLeast "6.16" no;
      # These don't technically require Rust but we probably want to get some more testing
      # on the whole DRM panic setup before shipping it by default.
      DRM_PANIC = whenAtLeast "6.12" yes;
      DRM_PANIC_SCREEN = whenAtLeast "6.12" (freeform "kmsg");
      DRM_PANIC_SCREEN_QR_CODE = whenAtLeast "6.12" yes;
      # Do not enable Nova drivers, which are still WIP. This is the Kconfig default.
      NOVA_CORE = whenAtLeast "6.15" no;
      RUST = yes;
    };

    # Include the CFQ I/O scheduler in the kernel, rather than as a
    # module, so that the initrd gets a good I/O scheduler.
    scheduler = {
      BFQ_GROUP_IOSCHED = yes;
      BLK_CGROUP = yes; # required by CFQ"
      BLK_CGROUP_IOCOST = yes;
      BLK_CGROUP_IOLATENCY = yes;
      IOSCHED_BFQ = module;
      MQ_IOSCHED_DEADLINE = yes;
      MQ_IOSCHED_KYBER = yes;
      # Enable CPU utilization clamping for RT tasks
      UCLAMP_TASK = yes;
      UCLAMP_TASK_GROUP = yes;
    };

    security = {
      # Report BUG() conditions and kill the offending process.
      BUG = yes;
      BUG_ON_DATA_CORRUPTION = yes;
      CRYPTO_DRBG_CTR = whenOlder "7.2" yes;
      # NIST SP800-90A DRBG modes - enabled by most distributions
      #   and required by some out-of-tree modules (ShuffleCake)
      #   This does not include the NSA-backdoored Dual-EC mode from the same NIST publication.
      CRYPTO_DRBG_HASH = whenOlder "7.2" yes;
      # https://googleprojectzero.blogspot.com/2019/11/bad-binder-android-in-wild-exploit.html
      DEBUG_LIST = whenOlder "6.6" yes;
      DEFAULT_SECURITY_APPARMOR = yes;
      DEVKMEM = lib.mkIf (!stdenv.hostPlatform.isAarch64) (whenOlder "5.13" no); # Disable /dev/kmem
      FORTIFY_SOURCE = option yes;
      HARDENED_USERCOPY = yes;
      # only when compiled as yes, TPM 2.0 will automatically seed the kernel RNG
      HW_RANDOM = yes;
      IMA = yes;
      INIT_ON_ALLOC_DEFAULT_ON = yes;
      IO_STRICT_DEVMEM = lib.mkDefault yes;
      IPE_PROP_FS_VERITY = whenAtLeast "6.12" yes;
      IPE_PROP_FS_VERITY_BUILTIN_SIG = whenAtLeast "6.12" yes;
      # enable temporary caching of the last request_key() result
      KEYS_REQUEST_CACHE = yes;
      # Enable KFENCE
      # See: https://docs.kernel.org/dev-tools/kfence.html
      KFENCE = whenAtLeast "5.12" yes;
      KMALLOC_PARTITION_CACHES = whenAtLeast "7.2" yes;
      KMALLOC_PARTITION_RANDOM = whenAtLeast "7.2" yes;
      # https://git.kernel.org/torvalds/c/aebc7b0d8d91bbc69e976909963046bc48bca4fd
      LIST_HARDENED = whenAtLeast "6.6" yes;
      MODULE_SIG = no; # r13y, generates a random key during build and bakes it in
      # Enable support for page poisoning. Still needs to be enabled on the command line to actually work.
      PAGE_POISONING = yes;
      # provides a register of persistent per-UID keyrings, useful for encrypting storage pools in stratis
      PERSISTENT_KEYRINGS = yes;
      RANDOMIZE_BASE = option yes;

      # Randomize kernel stack offset on syscall entry to make stack address dependent
      # attacks harder, supported since 5.13.
      # Only default enabled on AArch64 from 7.1 due to perf issues prior to that release
      # that were resolved in "randomize_kstack: Maintain kstack_offset per task"
      RANDOMIZE_KSTACK_OFFSET_DEFAULT = whenAtLeast (
        if stdenv.hostPlatform.isAarch64 then "7.1" else "5.13"
      ) yes;

      # randomized slab caches
      RANDOM_KMALLOC_CACHES = whenBetween "6.6" "7.2" yes;
      RANDOM_TRUST_BOOTLOADER = whenOlder "6.2" yes; # allow the bootloader to seed the RNG

      RANDOM_TRUST_CPU = lib.mkIf (with stdenv.hostPlatform; isPower64 || isS390 || isx86 || isAarch64) (
        whenOlder "6.2" yes
      ); # allow RDRAND to seed the RNG

      # Enable stack smashing protections in schedule()
      # See: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?h=v4.8&id=0d9e26329b0c9263d4d9e0422d80a0e73268c52f
      SCHED_STACK_END_CHECK = yes;
      SECURITY_APPARMOR = yes;
      SECURITY_DMESG_RESTRICT = yes;
      # IPE (Integrity Policy Enforcement) - LSM that can enforce file integrity based on
      # fs-verity measurements or dm-verity. Useful for verified boot and immutable /nix/store.
      SECURITY_IPE = whenAtLeast "6.12" yes;
      # The goal of Landlock is to enable to restrict ambient rights (e.g. global filesystem access) for a set of processes.
      # This does not have any effect if a program does not support it
      SECURITY_LANDLOCK = whenAtLeast "5.13" yes;
      # Depends on MODULE_SIG and only really helps when you sign your modules
      # and enforce signatures which we don't do by default.
      SECURITY_LOCKDOWN_LSM = no;
      # Prevent processes from ptracing non-children processes
      SECURITY_YAMA = option yes;
      # Randomize page allocator when page_alloc.shuffle=1
      SHUFFLE_PAGE_ALLOCATOR = yes;
      # Enable separate slab buckets for user controlled allocations
      # See: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=67f2df3b82d091ed095d0e47e1f3a9d3e18e4e41
      SLAB_BUCKETS = whenAtLeast "6.11" yes;
      STRICT_DEVMEM = lib.mkDefault yes; # Filter access to /dev/mem
      STRICT_KERNEL_RWX = yes;
      STRICT_MODULE_RWX = yes;
      USER_NS = yes; # Support for user namespaces
    }
    // lib.optionalAttrs stdenv.hostPlatform.isx86_64 {
      # AMD SME
      AMD_MEM_ENCRYPT = yes;
      # AMD Cryptographic Coprocessor (CCP)
      CRYPTO_DEV_CCP = yes;
      DEFAULT_MMAP_MIN_ADDR = freeform "65536";
      # Enable support for Intel Trust Domain Extensions (TDX)
      INTEL_TDX_GUEST = whenAtLeast "5.19" yes;
      # AMD SEV and AMD SEV-SE
      KVM_AMD_SEV = yes;
      MITIGATION_SLS = whenAtLeast "6.9" yes;
      # AMD SEV-SNP
      SEV_GUEST = whenAtLeast "5.19" module;
      # Mitigate straight line speculation at the cost of some file size
      SLS = whenBetween "5.17" "6.9" yes;
      TDX_GUEST_DRIVER = whenAtLeast "6.2" module;
      # Enable Intel SGX
      X86_SGX = whenAtLeast "5.11" yes;
      # Allow KVM guests to load SGX enclaves
      X86_SGX_KVM = whenAtLeast "5.13" yes;
      # Shadow stacks
      X86_USER_SHADOW_STACK = whenAtLeast "6.6" yes;
    }
    // lib.optionalAttrs stdenv.hostPlatform.isAarch64 {
      DEFAULT_MMAP_MIN_ADDR = freeform "32768";
    };

    sound = {
      SND_AC97_POWER_SAVE = yes; # AC97 Power-Saving Mode
      # 10s for the idle timeout, Fedora does 1, Arch does 10.
      # The kernel says we should do 10.
      # Read: https://docs.kernel.org/sound/designs/powersave.html
      SND_AC97_POWER_SAVE_DEFAULT = freeform "10";
      SND_DYNAMIC_MINORS = yes;
      SND_HDA_CODEC_CS8409 = whenAtLeast "6.6" module; # Cirrus Logic HDA Bridge CS8409
      SND_HDA_INPUT_BEEP = yes; # Support digital beep via input layer
      # Support configuring jack functions via fw mechanism at boot
      SND_HDA_PATCH_LOADER = yes;
      SND_HDA_POWER_SAVE_DEFAULT = freeform "10";
      SND_HDA_RECONFIG = yes; # Support reconfiguration of jack functions
      SND_OSSEMUL = yes;
      SND_USB_AUDIO_MIDI_V2 = whenAtLeast "6.5" yes;
      SND_USB_CAIAQ_INPUT = yes;
      # Enable Sound Open Firmware support
    }
    // lib.optionalAttrs (stdenv.hostPlatform.system == "x86_64-linux") {
      SND_SOC_INTEL_SOUNDWIRE_SOF_MACH = module;
      SND_SOC_INTEL_USER_FRIENDLY_LONG_NAMES = yes; # dep of SOF_MACH
      SND_SOC_SOF_ACPI = module;
      SND_SOC_SOF_APOLLOLAKE = whenAtLeast "5.12" module;
      SND_SOC_SOF_APOLLOLAKE_SUPPORT = whenOlder "5.12" yes;
      SND_SOC_SOF_CANNONLAKE = whenAtLeast "5.12" module;
      SND_SOC_SOF_CANNONLAKE_SUPPORT = whenOlder "5.12" yes;
      SND_SOC_SOF_COFFEELAKE = whenAtLeast "5.12" module;
      SND_SOC_SOF_COFFEELAKE_SUPPORT = whenOlder "5.12" yes;
      SND_SOC_SOF_COMETLAKE = whenAtLeast "5.12" module;
      SND_SOC_SOF_COMETLAKE_LP_SUPPORT = whenOlder "5.12" yes;
      SND_SOC_SOF_ELKHARTLAKE = whenAtLeast "5.12" module;
      SND_SOC_SOF_ELKHARTLAKE_SUPPORT = whenOlder "5.12" yes;
      SND_SOC_SOF_GEMINILAKE = whenAtLeast "5.12" module;
      SND_SOC_SOF_GEMINILAKE_SUPPORT = whenOlder "5.12" yes;
      SND_SOC_SOF_HDA_AUDIO_CODEC = yes;
      SND_SOC_SOF_HDA_LINK = yes;
      SND_SOC_SOF_ICELAKE = whenAtLeast "5.12" module;
      SND_SOC_SOF_ICELAKE_SUPPORT = whenOlder "5.12" yes;
      SND_SOC_SOF_INTEL_SOUNDWIRE_LINK = whenOlder "5.11" yes; # dep of SOF_MACH
      SND_SOC_SOF_INTEL_TOPLEVEL = yes;
      SND_SOC_SOF_JASPERLAKE = whenAtLeast "5.12" module;
      SND_SOC_SOF_JASPERLAKE_SUPPORT = whenOlder "5.12" yes;
      SND_SOC_SOF_MERRIFIELD = whenAtLeast "5.12" module;
      SND_SOC_SOF_MERRIFIELD_SUPPORT = whenOlder "5.12" yes;
      SND_SOC_SOF_PCI = module;
      SND_SOC_SOF_TIGERLAKE = whenAtLeast "5.12" module;
      SND_SOC_SOF_TIGERLAKE_SUPPORT = whenOlder "5.12" yes;
      SND_SOC_SOF_TOPLEVEL = yes;
    };

    staging = {
      # Enable staging drivers.  These are somewhat experimental, but
      # they generally don't hurt.
      STAGING = yes;
      STAGING_MEDIA = yes;
    };

    # Disable various self-test modules that have no use in a production system
    tests = {
      # This menu disables all/most of them on >= 4.16
      RUNTIME_TESTING_MENU = option no;
    }
    // {
      CRC32_SELFTEST = option no;
      CRYPTO_TEST = option no;
      EFI_TEST = option no;
      GLOB_SELFTEST = option no;
      LOCK_TORTURE_TEST = option no;
      MTD_TESTS = option no;
      NOTIFIER_ERROR_INJECTION = option no;
      RCU_SCALE_TEST = no;
      TEST_ASYNC_DRIVER_PROBE = option no;
      WW_MUTEX_SELFTEST = option no;
      XZ_DEC_TEST = option no;
    };

    timer = {
      # Enable Full Dynticks System.
      # NO_HZ_FULL depends on HAVE_VIRT_CPU_ACCOUNTING_GEN depends on 64BIT
      NO_HZ_FULL = lib.mkIf stdenv.hostPlatform.is64bit yes;
    };

    tracing = {
      BPF_EVENTS = yes;
      BPF_SYSCALL = yes;
      BPF_UNPRIV_DEFAULT_OFF = whenOlder "5.16" yes;
      FTRACE = yes;
      FTRACE_SYSCALLS = yes;
      FUNCTION_GRAPH_RETVAL = whenAtLeast "6.5" yes;
      FUNCTION_PROFILER = yes;
      FUNCTION_TRACER = yes;
      KPROBES = yes;
      RING_BUFFER_BENCHMARK = no;
      SCHED_TRACER = yes;
      STACK_TRACER = yes;
      UPROBE_EVENTS = option yes;
    };

    usb = {
      USB = yes; # compile USB core into kernel, so we can use USB_SERIAL_CONSOLE before modules
      # default to dual role mode
      USB_DWC2_DUAL_ROLE = yes;
      USB_DWC3_DUAL_ROLE = yes;
      USB_EHCI_ROOT_HUB_TT = yes; # Root Hub Transaction Translators
      USB_EHCI_TT_NEWSCHED = yes; # Improved transaction translator scheduling
      USB_HIDDEV = yes; # USB Raw HID Devices (like monitor controls and Uninterruptable Power Supplies)
      USB_XHCI_SIDEBAND = whenAtLeast "6.16" yes; # needed for audio offload
      # The default (=y) forces us to have the XHCI firmware available in initrd,
      # which our initrd builder can't currently do easily.
      USB_XHCI_TEGRA = lib.mkIf stdenv.hostPlatform.isAarch64 module;
    };

    usb-serial = {
      USB_SERIAL = yes;
      USB_SERIAL_CONSOLE = yes; # Allow using USB serial adapter as console
      USB_SERIAL_GENERIC = yes; # USB Generic Serial Driver
      U_SERIAL_CONSOLE = yes; # Allow using USB gadget as console
    };

    video =
      let
        whenHasDevicePrivate = lib.mkIf (
          with stdenv.hostPlatform;
          isLoongArch64
          || isPower64
          || isS390x
          || isx86_64
          || isAarch64
          || (lib.versionAtLeast version "6.11" && isRiscV64)
        );
      in
      {
        # compile in DRM so simpledrm can load before initrd if necessary
        AGP = lib.mkIf (with stdenv.hostPlatform; isPower || isx86) yes;
        # Must be the same as CONFIG_DRM
        BACKLIGHT_CLASS_DEVICE = yes;
        # Enable Nouveau shared virtual memory (used by OpenCL)
        DEVICE_PRIVATE = whenHasDevicePrivate yes;
        DRM = yes;
        # (stable) amdgpu support for bonaire and newer chipsets
        DRM_AMDGPU_CIK = yes;
        # (experimental) amdgpu support for verde and newer chipsets
        DRM_AMDGPU_SI = yes;
        # Enable AMD Audio Coprocessor support for HDMI outputs
        DRM_AMD_ACP = yes;

        DRM_AMD_DC_DCN = lib.mkIf (with stdenv.hostPlatform; isx86 || isPower64) (
          whenBetween "5.11" "6.4" yes
        );

        # amdgpu display core (DC) support
        DRM_AMD_DC_DCN3_0 = lib.mkIf (with stdenv.hostPlatform; isx86) (whenOlder "5.11" yes);
        # Not available when using clang
        # See: https://github.com/torvalds/linux/blob/172a9d94339cea832d89630b89d314e41d622bd8/drivers/gpu/drm/amd/display/Kconfig#L14
        DRM_AMD_DC_FP = lib.mkIf (!stdenv.cc.isClang) (whenAtLeast "6.4" yes);
        DRM_AMD_DC_HDCP = whenOlder "6.4" yes;
        DRM_AMD_DC_SI = yes;
        # Enable AMD image signal processor
        DRM_AMD_ISP = whenAtLeast "6.11" yes;

        # Enable AMD secure display when available
        DRM_AMD_SECURE_DISPLAY = lib.mkIf (
          with stdenv.hostPlatform;
          (lib.versionAtLeast version "5.13" && (isx86 || isPower64))
          || (lib.versionAtLeast version "6.2" && isAarch64 && !stdenv.cc.isClang)
          || (lib.versionAtLeast version "6.5" && isLoongArch64 && !stdenv.cc.isClang)
          || (lib.versionAtLeast version "6.10" && isRiscV64 && !stdenv.cc.isClang)
        ) yes;

        DRM_DISPLAY_DP_AUX_CEC = whenAtLeast "6.10" yes;
        DRM_DISPLAY_DP_AUX_CHARDEV = whenAtLeast "6.10" yes;
        # Allow device firmware updates
        DRM_DP_AUX_CHARDEV = whenOlder "6.10" yes;
        # Enable CEC over DisplayPort
        DRM_DP_CEC = whenOlder "6.10" yes;
        DRM_GMA3600 = lib.mkIf stdenv.hostPlatform.isx86 (whenOlder "5.12" yes);
        DRM_GMA500 = lib.mkIf stdenv.hostPlatform.isx86 (whenAtLeast "5.12" module);
        DRM_GMA600 = lib.mkIf stdenv.hostPlatform.isx86 (whenOlder "5.13" yes);
        DRM_LEGACY = whenOlder "6.8" no;
        # Allow specifying custom EDID on the kernel command line
        DRM_LOAD_EDID_FIRMWARE = yes;
        # Enable new firmware (and by extension NVK) for compatible hardware on Nouveau
        DRM_NOUVEAU_GSP_DEFAULT = whenBetween "6.8" "6.18" yes;
        DRM_NOUVEAU_SVM = whenHasDevicePrivate yes;
        # Enable RAS reporting via netlink
        DRM_RAS = whenAtLeast "7.1" yes;
        # Enable simpledrm and use it for generic framebuffer
        # Technically added in 5.14, but adding more complex configuration is not worth it
        DRM_SIMPLEDRM = whenAtLeast "5.15" yes;
        DRM_VMWGFX_FBCON = lib.mkIf stdenv.hostPlatform.isx86 (whenOlder "6.1" yes);
        MEDIA_CEC_RC = yes;
        NOUVEAU_LEGACY_CTX_SUPPORT = whenOlder "6.3" no;
        # Enable HDMI-CEC receiver support
        RC_CORE = yes;
        SYSFB_SIMPLEFB = whenAtLeast "5.15" yes;
        VGA_SWITCHEROO = lib.mkIf stdenv.hostPlatform.isx86 yes; # Hybrid graphics support
      }
      //
        lib.optionalAttrs
          (stdenv.hostPlatform.system == "x86_64-linux" || stdenv.hostPlatform.system == "aarch64-linux")
          {
            # Enable Hyper-V Synthetic DRM Driver
            DRM_HYPERV = whenAtLeast "5.14" module;
            # And disable the legacy framebuffer driver when we have the new one
            FB_HYPERV = whenBetween "5.14" "7.0" no;
            # Enable Hyper-V guest stuff
            HYPERV = whenAtLeast "6.18" yes;
          }
      // lib.optionalAttrs (stdenv.hostPlatform.system == "x86_64-linux") {
        # Intel GVT-g graphics virtualization supports 64-bit only
        DRM_I915_GVT = yes;
        DRM_I915_GVT_KVMGT = module;
      }
      // lib.optionalAttrs (stdenv.hostPlatform.system == "aarch64-linux") {
        # enable HDMI-CEC on RPi boards
        DRM_VC4_HDMI_CEC = yes;
        # Enable HDMI out on platforms using the RK3588 lineup of SoCs.
        ROCKCHIP_DW_HDMI_QP = whenAtLeast "6.13" yes;
        # Enable DSI out on platforms using the RK3588 lineup of SoCs.
        ROCKCHIP_DW_MIPI_DSI2 = whenAtLeast "6.16" yes;
      };

    virtualisation = {
      # Loongson Binary Translation extension, required for running
      # x86 and x86_64 binaries via LATX or similar emulators
      CPU_HAS_LBT = lib.mkIf stdenv.hostPlatform.isLoongArch64 (option yes);

      # We need 64 GB (PAE) support for Xen guest support
      HIGHMEM64G = whenOlder "6.15" {
        optional = true;
        tristate = lib.mkIf (!stdenv.hostPlatform.is64bit) "y";
      };

      HVC_XEN = option yes;
      HVC_XEN_FRONTEND = option yes;
      HYPERVISOR_GUEST = lib.mkIf stdenv.hostPlatform.isx86 yes;
      KSM = yes;
      KVM_ASYNC_PF = lib.mkIf (with stdenv.hostPlatform; isS390 || isx86) yes;
      KVM_GENERIC_DIRTYLOG_READ_PROTECT = yes;
      KVM_GUEST = lib.mkIf (with stdenv.hostPlatform; isPower || isx86) yes;
      KVM_MMIO = yes;
      KVM_VFIO = yes;
      PARAVIRT = option yes;
      PARAVIRT_SPINLOCKS = option yes;
      PCI_XEN = option yes;
      SWIOTLB_XEN = option yes;
      UDMABUF = yes;
      # Enable CDEV and NOIOMMU support for VFIO, which is useful for
      # passthrough.
      VFIO_DEVICE_CDEV = whenAtLeast "6.6" yes;
      VFIO_NOIOMMU = whenAtLeast "6.6" yes;
      VFIO_PCI_VGA = lib.mkIf stdenv.hostPlatform.isx86_64 yes;
      # Disabled by default on POWER
      VIRTIO_MENU = yes;
      # Enable device detection on virtio-mmio hypervisors
      VIRTIO_MMIO_CMDLINE_DEVICES = yes;
      VIRT_DRIVERS = yes;
      XEN = option yes;
      XEN_BACKEND = option yes;
      XEN_BALLOON = option yes;
      XEN_BALLOON_MEMORY_HOTPLUG = option yes;
      XEN_DOM0 = option yes;
      XEN_EFI = option yes;
      XEN_HAVE_PVMMU = option yes;
      XEN_MCE_LOG = option yes;
      XEN_PVH = option yes;
      XEN_PVHVM = option yes;
      XEN_SAVE_RESTORE = option yes;
      XEN_SYS_HYPERVISOR = option yes;
    };

    wireless = {
      ATH10K_DFS_CERTIFIED = option yes;
      ATH9K_AHB = option yes; # Ditto, AHB bus
      # DFS: "Dynamic Frequency Selection" is a spectrum-sharing mechanism that allows
      # you to use certain interesting frequency when your local regulatory domain mandates it.
      # ATH drivers hides the feature behind this option and makes hostapd works with DFS frequencies.
      # OpenWRT enables it too: https://github.com/openwrt/openwrt/blob/master/package/kernel/mac80211/ath.mk#L42
      ATH9K_DFS_CERTIFIED = option yes;
      ATH9K_PCI = option yes; # Detect Atheros AR9xxx cards on PCI(e) bus
      B43_PHY_HT = option yes;
      BCMA_HOST_PCI = option yes;
      CFG80211_CERTIFICATION_ONUS = option yes;
      CFG80211_WEXT = option yes; # Without it, ipw2200 drivers don't build
      # The description of this option makes it sound dangerous or even illegal
      # But OpenWRT enables it by default: https://github.com/openwrt/openwrt/blob/master/package/kernel/mac80211/Makefile#L55
      # At the time of writing (25-06-2023): this is only used in a "correct" way by ath drivers for initiating DFS radiation
      # for "certified devices"
      EXPERT = option yes; # this is needed for offering the certification option
      HOSTAP_FIRMWARE = whenOlder "6.8" (option yes); # Support downloading firmware images with Host AP driver
      HOSTAP_FIRMWARE_NVRAM = whenOlder "6.8" (option yes);
      IPW2100_MONITOR = option yes; # support promiscuous mode
      IPW2200_MONITOR = option yes; # support promiscuous mode
      MAC80211_MESH = option yes; # Enable 802.11s (mesh networking) support
      RFKILL_INPUT = option yes; # counteract an undesired effect of setting EXPERT
      # Enable "untested" hardware support for RTL8xxxU.
      # There's a bunch of those still floating around,
      # and given how old the hardware is, we're unlikely
      # to kill any, so let's enable all known device IDs.
      RTL8XXXU_UNTESTED = option yes;
      RTW88 = module;
      RTW88_8822BE = module;
      RTW88_8822CE = module;
    };

    # Support x2APIC (which requires IRQ remapping)
    x2apic = lib.optionalAttrs (stdenv.hostPlatform.system == "x86_64-linux") {
      IRQ_REMAP = yes;
      X86_X2APIC = yes;
    };

    zram = {
      ZPOOL = whenOlder "6.18" yes;
      ZRAM = module;
      ZRAM_BACKEND_842 = whenAtLeast "6.12" yes;
      ZRAM_BACKEND_DEFLATE = whenAtLeast "6.12" yes;
      ZRAM_BACKEND_LZ4 = whenAtLeast "6.12" yes;
      ZRAM_BACKEND_LZ4HC = whenAtLeast "6.12" yes;
      ZRAM_BACKEND_LZO = whenAtLeast "6.12" yes;
      ZRAM_BACKEND_ZSTD = whenAtLeast "6.12" yes;
      ZRAM_DEF_COMP_ZSTD = whenAtLeast "5.11" yes;
      ZRAM_MULTI_COMP = whenAtLeast "6.2" yes;
      ZRAM_WRITEBACK = option yes;
      ZSMALLOC = option yes;
      ZSWAP = option yes;
      ZSWAP_COMPRESSOR_DEFAULT_ZSTD = lib.mkOptionDefault yes;
    };
  };
in
flattenKConf options
