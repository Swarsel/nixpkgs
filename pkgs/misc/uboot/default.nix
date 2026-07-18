{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  armTrustedFirmwareAllwinner,
  armTrustedFirmwareAllwinnerH6,
  armTrustedFirmwareAllwinnerH616,
  armTrustedFirmwareRK3328,
  armTrustedFirmwareRK3399,
  armTrustedFirmwareRK3568,
  armTrustedFirmwareRK3588,
  armTrustedFirmwareS905,
  bc,
  bison,
  buildPackages,
  callPackages,
  darwin,
  dtc,
  fetchpatch,
  flex,
  gnutls,
  installShellFiles,
  libuuid,
  meson-tools,
  ncurses,
  opensbi,
  openssl,
  perl,
  python3,
  rkbin,
  swig,
  which,
}@pkgs:

let
  defaultVersion = "2026.07";
  defaultSrc = fetchurl {
    hash = "sha256-eOi/w4L+OI+bVaodr4xWNSKgN3ebXUw0nRQV44HxJD4=";
    url = "https://ftp.denx.de/pub/u-boot/u-boot-${defaultVersion}.tar.bz2";
  };

  # Dependencies for the tools need to be included as either native or cross,
  # depending on which we're building
  toolsDeps = [
    ncurses # tools/kwboot
    libuuid # tools/mkeficapsule
    gnutls # tools/mkeficapsule
    openssl # tools/mkimage and tools/env/fw_printenv
  ];

  buildUBoot = lib.makeOverridable (
    {
      stdenv ? pkgs.stdenv,
      defconfig,
      filesToInstall,
      crossTools ? false,
      extraConfig ? "",
      extraMakeFlags ? [ ],
      extraMeta ? { },
      extraPatches ? [ ],
      installDir ? "$out",
      pythonScriptsToInstall ? { },
      src ? null,
      version ? null,
      ...
    }@args:
    stdenv.mkDerivation (
      {
        pname = "uboot-${defconfig}";
        version = if src == null then defaultVersion else version;
        src = if src == null then defaultSrc else src;
        patches = extraPatches;

        postPatch = ''
          ${lib.concatMapStrings (script: ''
            substituteInPlace ${script} \
            --replace "#!/usr/bin/env python3" "#!${pythonScriptsToInstall.${script}}/bin/python3"
          '') (builtins.attrNames pythonScriptsToInstall)}
          patchShebangs tools
          patchShebangs scripts
        '';

        nativeBuildInputs = [
          ncurses # tools/kwboot
          bc
          bison
          flex
          installShellFiles
          (buildPackages.python3.withPackages (p: [
            p.libfdt
            p.setuptools # for pkg_resources
            p.pyelftools
          ]))
          swig
          which # for scripts/dtc-version.sh
          perl # for oid build (secureboot)
        ]
        ++ lib.optionals (!crossTools) toolsDeps
        ++ lib.optionals stdenv.buildPlatform.isDarwin [ darwin.DarwinTools ]; # sw_vers command is needed on darwin

        buildInputs = lib.optionals crossTools toolsDeps;

        makeFlags = [
          "DTC=${lib.getExe buildPackages.dtc}"
          "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
          "HOSTCFLAGS=-fcommon"
        ]
        ++ extraMakeFlags;

        installPhase = ''
          runHook preInstall

          mkdir -p ${installDir}
          cp ${
            lib.concatStringsSep " " (filesToInstall ++ builtins.attrNames pythonScriptsToInstall)
          } ${installDir}

          mkdir -p "$out/nix-support"
          ${lib.concatMapStrings (file: ''
            echo "file binary-dist ${installDir}/${baseNameOf file}" >> "$out/nix-support/hydra-build-products"
          '') (filesToInstall ++ builtins.attrNames pythonScriptsToInstall)}

          runHook postInstall
        '';

        __structuredAttrs = true;

        configurePhase = ''
          runHook preConfigure

          make -j$NIX_BUILD_CORES ${defconfig}

          printf "%s" "$extraConfig" >> .config

          runHook postConfigure
        '';

        depsBuildBuild = [ buildPackages.gccStdenv.cc ]; # gccStdenv is needed for Darwin buildPlatform
        dontStrip = true;
        enableParallelBuilding = true;
        hardeningDisable = [ "all" ];

        meta = {
          description = "Boot loader for embedded systems";
          homepage = "https://www.denx.de/wiki/U-Boot/";
          license = lib.licenses.gpl2Plus;

          maintainers = with lib.maintainers; [
            lopsided98
          ];
        }
        // extraMeta;
      }
      // removeAttrs args [
        "extraMeta"
        "pythonScriptsToInstall"
      ]
    )
  );
in
{
  inherit buildUBoot;

  ubootA20OlinuxinoLime = buildUBoot {
    defconfig = "A20-OLinuXino-Lime_defconfig";
    extraMeta.platforms = [ "armv7l-linux" ];
    filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
  };

  ubootA20OlinuxinoLime2EMMC = buildUBoot {
    defconfig = "A20-OLinuXino-Lime2-eMMC_defconfig";
    extraMeta.platforms = [ "armv7l-linux" ];
    filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
  };

  ubootAmx335xEVM = buildUBoot {
    defconfig = "am335x_evm_defconfig";

    extraMeta = {
      broken = true; # too big, exceeds memory size
      platforms = [ "armv7l-linux" ];
    };

    filesToInstall = [
      "MLO"
      "u-boot.img"
    ];
  };

  ubootBananaPi = buildUBoot {
    defconfig = "Bananapi_defconfig";
    extraMeta.platforms = [ "armv7l-linux" ];
    filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
  };

  ubootBananaPim2Zero = buildUBoot {
    defconfig = "bananapi_m2_zero_defconfig";
    extraMeta.platforms = [ "armv7l-linux" ];
    filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
  };

  ubootBananaPim3 = buildUBoot {
    defconfig = "Sinovoip_BPI_M3_defconfig";
    extraMeta.platforms = [ "armv7l-linux" ];
    filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
  };

  ubootBananaPim64 = buildUBoot {
    env = {
      BL31 = "${armTrustedFirmwareAllwinner}/bl31.bin";
      SCP = "/dev/null";
    };

    defconfig = "bananapi_m64_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];
    filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
  };

  ubootCM3588NAS = buildUBoot {
    env = {
      BL31 = "${armTrustedFirmwareRK3588}/bl31.elf";
      ROCKCHIP_TPL = rkbin.TPL_RK3588;
    };

    defconfig = "cm3588-nas-rk3588_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];

    filesToInstall = [
      "u-boot.itb"
      "idbloader.img"
      "u-boot-rockchip.bin"
    ];
  };

  # http://git.denx.de/?p=u-boot.git;a=blob;f=board/solidrun/clearfog/README;hb=refs/heads/master
  ubootClearfog = buildUBoot {
    defconfig = "clearfog_defconfig";
    extraMeta.platforms = [ "armv7l-linux" ];
    filesToInstall = [ "u-boot-with-spl.kwb" ];
  };

  ubootCubieboard2 = buildUBoot {
    defconfig = "Cubieboard2_defconfig";
    extraMeta.platforms = [ "armv7l-linux" ];
    filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
  };

  ubootGuruplug = buildUBoot {
    defconfig = "guruplug_defconfig";
    extraMeta.platforms = [ "armv5tel-linux" ];
    filesToInstall = [ "u-boot.bin" ];
  };

  ubootJetsonTK1 = buildUBoot {
    # tegra-uboot-flasher expects this exact directory layout, sigh...
    postInstall = ''
      mkdir -p $out/spl
      cp spl/u-boot-spl $out/spl/
    '';

    defconfig = "jetson-tk1_defconfig";
    extraMeta.platforms = [ "armv7l-linux" ];

    filesToInstall = [
      "u-boot"
      "u-boot.dtb"
      "u-boot-dtb-tegra.bin"
      "u-boot-nodtb-tegra.bin"
    ];
  };

  ubootLibreTechCC =
    let
      firmwareImagePkg = fetchFromGitHub {
        owner = "LibreELEC";
        repo = "amlogic-boot-fip";
        rev = "4369a138ca24c5ab932b8cbd1af4504570b709df";
        sha256 = "sha256-mGRUwdh3nW4gBwWIYHJGjzkezHxABwcwk/1gVRis7Tc=";
        meta.license = lib.licenses.unfreeRedistributableFirmware;
      };
    in
    buildUBoot {
      postBuild = ''
        # Copy binary files & tools from LibreELEC/amlogic-boot-fip, and u-boot build to working dir
        mkdir $out tmp
        cp ${firmwareImagePkg}/lepotato/{acs.bin,bl2.bin,bl21.bin,bl30.bin,bl301.bin,bl31.img} \
           ${firmwareImagePkg}/lepotato/{acs_tool.py,aml_encrypt_gxl,blx_fix.sh} \
           u-boot.bin tmp/
        cd tmp
        python3 acs_tool.py bl2.bin bl2_acs.bin acs.bin 0

        bash -e blx_fix.sh bl2_acs.bin zero bl2_zero.bin bl21.bin bl21_zero.bin bl2_new.bin bl2
        [ -f zero ] && rm zero

        bash -e blx_fix.sh bl30.bin zero bl30_zero.bin bl301.bin bl301_zero.bin bl30_new.bin bl30
        [ -f zero ] && rm zero

        ./aml_encrypt_gxl --bl2sig --input bl2_new.bin --output bl2.n.bin.sig
        ./aml_encrypt_gxl --bl3enc --input bl30_new.bin --output bl30_new.bin.enc
        ./aml_encrypt_gxl --bl3enc --input bl31.img --output bl31.img.enc
        ./aml_encrypt_gxl --bl3enc --input u-boot.bin --output bl33.bin.enc
        ./aml_encrypt_gxl --bootmk --output $out/u-boot.gxl \
          --bl2 bl2.n.bin.sig --bl30 bl30_new.bin.enc --bl31 bl31.img.enc --bl33 bl33.bin.enc
      '';

      defconfig = "libretech-cc_defconfig";

      extraMeta = {
        broken = stdenv.buildPlatform.system != "x86_64-linux"; # aml_encrypt_gxl is a x86_64 binary

        longDescription = ''
          Boot loader for the Libre Computer AML-S905X-CC.

          Flashing instructions:
          ```sh
          dd if=u-boot.gxl.sd.bin of=<sdcard> conv=fsync,notrunc bs=512 skip=1 seek=1
          dd if=u-boot.gxl.sd.bin of=<sdcard> conv=fsync,notrunc bs=1 count=444
          ```
        '';

        platforms = [ "aarch64-linux" ];
      };

      filesToInstall = [ "u-boot.bin" ];
    };

  ubootNanoPCT4 = buildUBoot rec {
    env.BL31 = "${armTrustedFirmwareRK3399}/bl31.elf";

    postBuild = ''
      ./tools/mkimage -n rk3399 -T rksd -d ${rkbin}/rk33/rk3399_ddr_800MHz_v1.24.bin idbloader.img
      cat ${rkbin}/rk33/rk3399_miniloader_v1.19.bin >> idbloader.img
    '';

    defconfig = "nanopc-t4-rk3399_defconfig";

    extraMeta = {
      license = lib.licenses.unfreeRedistributableFirmware;
      platforms = [ "aarch64-linux" ];
    };

    filesToInstall = [
      "u-boot.itb"
      "idbloader.img"
    ];

    rkbin = fetchFromGitHub {
      owner = "armbian";
      repo = "rkbin";
      rev = "3bd0321cae5ef881a6005fb470009ad5a5d1462d";
      sha256 = "09r4dzxsbs3pff4sh70qnyp30s3rc7pkc46v1m3152s7jqjasp31";
    };
  };

  ubootNanoPCT6 = buildUBoot {
    env = {
      BL31 = "${armTrustedFirmwareRK3588}/bl31.elf";
      ROCKCHIP_TPL = rkbin.TPL_RK3588;
    };

    defconfig = "nanopc-t6-rk3588_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];

    filesToInstall = [
      "u-boot.itb"
      "idbloader.img"
      "u-boot-rockchip.bin"
      "u-boot-rockchip-spi.bin"
    ];
  };

  ubootNanoPiR5S = buildUBoot {
    env = {
      BL31 = rkbin.BL31_RK3568;
      ROCKCHIP_TPL = rkbin.TPL_RK3568;
    };

    defconfig = "nanopi-r5s-rk3568_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];

    filesToInstall = [
      "idbloader.img"
      "u-boot.itb"
    ];
  };

  ubootNovena = buildUBoot {
    defconfig = "novena_defconfig";
    extraMeta.platforms = [ "armv7l-linux" ];

    filesToInstall = [
      "u-boot-dtb.img"
      "SPL"
    ];
  };

  ubootOdroidC2 =
    let
      firmwareBlobs = fetchFromGitHub {
        owner = "armbian";
        repo = "odroidc2-blobs";
        rev = "47c5aac4bcac6f067cebe76e41fb9924d45b429c";
        sha256 = "1ns0a130yxnxysia8c3q2fgyjp9k0nkr689dxk88qh2vnibgchnp";
        meta.license = lib.licenses.unfreeRedistributableFirmware;
      };
    in
    buildUBoot {
      postBuild = ''
        # BL301 image needs at least 64 bytes of padding after it to place
        # signing headers (with amlbootsig)
        truncate -s 64 bl301.padding.bin
        cat '${firmwareBlobs}/gxb/bl301.bin' bl301.padding.bin > bl301.padded.bin
        # The downstream fip_create tool adds a custom TOC entry with UUID
        # AABBCCDD-ABCD-EFEF-ABCD-12345678ABCD for the BL301 image. It turns out
        # that the firmware blob does not actually care about UUIDs, only the
        # order the images appear in the file. Because fiptool does not know
        # about the BL301 UUID, we would have to use the --blob option, which adds
        # the image to the end of the file, causing the boot to fail. Instead, we
        # take advantage of the fact that UUIDs are ignored and just put the
        # images in the right order with the wrong UUIDs. In the command below,
        # --tb-fw is really --scp-fw and --scp-fw is the BL301 image.
        #
        # See https://github.com/afaerber/meson-tools/issues/3 for more
        # information.
        '${buildPackages.armTrustedFirmwareTools}/bin/fiptool' create \
          --align 0x4000 \
          --tb-fw '${firmwareBlobs}/gxb/bl30.bin' \
          --scp-fw bl301.padded.bin \
          --soc-fw '${armTrustedFirmwareS905}/bl31.bin' \
          --nt-fw u-boot.bin \
          fip.bin
        cat '${firmwareBlobs}/gxb/bl2.package' fip.bin > boot_new.bin
        '${buildPackages.meson-tools}/bin/amlbootsig' boot_new.bin u-boot.img
        dd if=u-boot.img of=u-boot.gxbb bs=512 skip=96
      '';

      defconfig = "odroid-c2_defconfig";

      extraMeta = {
        longDescription = ''
          Boot loader for the Hardkernel ODROID-C2.

          Flashing instructions:
          ```sh
          dd if=bl1.bin.hardkernel of=<device> conv=fsync bs=1 count=442
          dd if=bl1.bin.hardkernel of=<device> conv=fsync bs=512 skip=1 seek=1
          dd if=u-boot.gxbb of=<device> conv=fsync bs=512 seek=97
          ```
        '';

        platforms = [ "aarch64-linux" ];
      };

      filesToInstall = [
        "u-boot.bin"
        "u-boot.gxbb"
        "${firmwareBlobs}/bl1.bin.hardkernel"
      ];
    };

  ubootOdroidXU3 = buildUBoot {
    defconfig = "odroid-xu3_defconfig";
    extraMeta.platforms = [ "armv7l-linux" ];
    filesToInstall = [ "u-boot-dtb.bin" ];
  };

  ubootOlimexA64Olinuxino = buildUBoot {
    env = {
      BL31 = "${armTrustedFirmwareAllwinner}/bl31.bin";
      SCP = "/dev/null";
    };

    defconfig = "a64-olinuxino-emmc_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];
    filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
  };

  ubootOlimexA64Teres1 = buildUBoot {
    env = {
      BL31 = "${armTrustedFirmwareAllwinner}/bl31.bin";
      # Using /dev/null here is upstream-specified way that disables the inclusion of crust-firmware as it's not yet packaged and without which the build will fail -- https://docs.u-boot.org/en/latest/board/allwinner/sunxi.html#building-the-crust-management-processor-firmware
      SCP = "/dev/null";
    };

    defconfig = "teres_i_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];
    filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
  };

  ubootOrangePi3 = buildUBoot {
    env = {
      BL31 = "${armTrustedFirmwareAllwinnerH6}/bl31.bin";
      SCP = "/dev/null";
    };

    defconfig = "orangepi_3_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];
    filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
  };

  ubootOrangePi3B = buildUBoot {
    env = {
      BL31 = rkbin.BL31_RK3568;
      ROCKCHIP_TPL = rkbin.TPL_RK3568;
    };

    defconfig = "orangepi-3b-rk3566_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];

    filesToInstall = [
      "u-boot.itb"
      "idbloader.img"
      "u-boot-rockchip.bin"
      "u-boot-rockchip-spi.bin"
    ];
  };

  ubootOrangePi5 = buildUBoot {
    env = {
      BL31 = "${armTrustedFirmwareRK3588}/bl31.elf";
      ROCKCHIP_TPL = rkbin.TPL_RK3588;
    };

    defconfig = "orangepi-5-rk3588s_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];

    filesToInstall = [
      "u-boot.itb"
      "idbloader.img"
      "u-boot-rockchip.bin"
      "u-boot-rockchip-spi.bin"
    ];
  };

  ubootOrangePi5Max = buildUBoot {
    env = {
      BL31 = "${armTrustedFirmwareRK3588}/bl31.elf";
      ROCKCHIP_TPL = rkbin.TPL_RK3588;
    };

    defconfig = "orangepi-5-max-rk3588_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];

    filesToInstall = [
      "u-boot.itb"
      "idbloader.img"
      "u-boot-rockchip.bin"
      "u-boot-rockchip-spi.bin"
    ];
  };

  ubootOrangePi5Plus = buildUBoot {
    env = {
      BL31 = "${armTrustedFirmwareRK3588}/bl31.elf";
      ROCKCHIP_TPL = rkbin.TPL_RK3588;
    };

    defconfig = "orangepi-5-plus-rk3588_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];

    filesToInstall = [
      "u-boot.itb"
      "idbloader.img"
      "u-boot-rockchip.bin"
      "u-boot-rockchip-spi.bin"
    ];
  };

  ubootOrangePiPc = buildUBoot {
    defconfig = "orangepi_pc_defconfig";
    extraMeta.platforms = [ "armv7l-linux" ];
    filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
  };

  ubootOrangePiZero = buildUBoot {
    defconfig = "orangepi_zero_defconfig";
    extraMeta.platforms = [ "armv7l-linux" ];
    filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
  };

  ubootOrangePiZero2 = buildUBoot {
    env.BL31 = "${armTrustedFirmwareAllwinnerH616}/bl31.bin";
    defconfig = "orangepi_zero2_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];
    filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
  };

  ubootOrangePiZero3 = buildUBoot {
    # According to https://linux-sunxi.org/H616 the H618 "is a minor update with a larger (1MB) L2 cache" (compared to the H616)
    # but "does require extra support in U-Boot, TF-A and sunxi-fel. Support for that has been merged in mainline releases."
    # But no extra support seems to be in TF-A.
    env.BL31 = "${armTrustedFirmwareAllwinnerH616}/bl31.bin";
    defconfig = "orangepi_zero3_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];
    filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
  };

  ubootOrangePiZeroPlus2H5 = buildUBoot {
    env = {
      BL31 = "${armTrustedFirmwareAllwinner}/bl31.bin";
      SCP = "/dev/null";
    };

    defconfig = "orangepi_zero_plus2_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];
    filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
  };

  ubootPcduino3Nano = buildUBoot {
    defconfig = "Linksprite_pcDuino3_Nano_defconfig";
    extraMeta.platforms = [ "armv7l-linux" ];
    filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
  };

  ubootPine64 = buildUBoot {
    env = {
      BL31 = "${armTrustedFirmwareAllwinner}/bl31.bin";
      SCP = "/dev/null";
    };

    defconfig = "pine64_plus_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];
    filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
  };

  ubootPine64LTS = buildUBoot {
    env = {
      BL31 = "${armTrustedFirmwareAllwinner}/bl31.bin";
      SCP = "/dev/null";
    };

    defconfig = "pine64-lts_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];
    filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
  };

  ubootPinebook = buildUBoot {
    env = {
      BL31 = "${armTrustedFirmwareAllwinner}/bl31.bin";
      SCP = "/dev/null";
    };

    defconfig = "pinebook_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];
    filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
  };

  ubootPinebookPro = buildUBoot {
    env.BL31 = "${armTrustedFirmwareRK3399}/bl31.elf";
    defconfig = "pinebook-pro-rk3399_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];

    filesToInstall = [
      "u-boot.itb"
      "idbloader.img"
    ];
  };

  ubootPythonTools = lib.recurseIntoAttrs (callPackages ./python.nix { });

  ubootQemuAarch64 = buildUBoot {
    defconfig = "qemu_arm64_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];
    filesToInstall = [ "u-boot.bin" ];
  };

  ubootQemuArm = buildUBoot {
    defconfig = "qemu_arm_defconfig";
    extraMeta.platforms = [ "armv7l-linux" ];
    filesToInstall = [ "u-boot.bin" ];
  };

  ubootQemuRiscv64Smode = buildUBoot {
    defconfig = "qemu-riscv64_smode_defconfig";
    extraMeta.platforms = [ "riscv64-linux" ];
    filesToInstall = [ "u-boot.bin" ];
  };

  ubootQemuX86 = buildUBoot {
    defconfig = "qemu-x86_defconfig";

    extraConfig = ''
      CONFIG_USB_UHCI_HCD=y
      CONFIG_USB_EHCI_HCD=y
      CONFIG_USB_EHCI_GENERIC=y
      CONFIG_USB_XHCI_HCD=y
    '';

    extraMeta.platforms = [
      "i686-linux"
      "x86_64-linux"
    ];

    filesToInstall = [ "u-boot.rom" ];
  };

  ubootQemuX86_64 = buildUBoot {
    defconfig = "qemu-x86_64_defconfig";

    extraConfig = ''
      CONFIG_USB_UHCI_HCD=y
      CONFIG_USB_EHCI_HCD=y
      CONFIG_USB_EHCI_GENERIC=y
      CONFIG_USB_XHCI_HCD=y
    '';

    extraMeta.platforms = [ "x86_64-linux" ];
    filesToInstall = [ "u-boot.rom" ];
  };

  ubootQuartz64B = buildUBoot {
    env = {
      BL31 = "${armTrustedFirmwareRK3568}/bl31.elf";
      ROCKCHIP_TPL = rkbin.TPL_RK3566;
    };

    defconfig = "quartz64-b-rk3566_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];

    filesToInstall = [
      "idbloader.img"
      "idbloader-spi.img"
      "u-boot.itb"
      "u-boot-rockchip.bin"
      "u-boot-rockchip-spi.bin"
    ];
  };

  ubootROCPCRK3399 = buildUBoot {
    env.BL31 = "${armTrustedFirmwareRK3399}/bl31.elf";
    defconfig = "roc-pc-rk3399_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];

    filesToInstall = [
      "spl/u-boot-spl.bin"
      "u-boot.itb"
      "idbloader.img"
    ];
  };

  ubootRadxaZero3W = buildUBoot {
    env = {
      BL31 = "${armTrustedFirmwareRK3568}/bl31.elf";
      ROCKCHIP_TPL = rkbin.TPL_RK3566;
    };

    defconfig = "radxa-zero-3-rk3566_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];

    filesToInstall = [
      "idbloader.img"
      "u-boot.itb"
      "u-boot-rockchip.bin"
    ];
  };

  ubootRaspberryPi = buildUBoot {
    defconfig = "rpi_defconfig";
    extraMeta.platforms = [ "armv6l-linux" ];
    filesToInstall = [ "u-boot.bin" ];
  };

  ubootRaspberryPi2 = buildUBoot {
    defconfig = "rpi_2_defconfig";
    extraMeta.platforms = [ "armv7l-linux" ];
    filesToInstall = [ "u-boot.bin" ];
  };

  ubootRaspberryPi3_32bit = buildUBoot {
    defconfig = "rpi_3_32b_defconfig";
    extraMeta.platforms = [ "armv7l-linux" ];
    filesToInstall = [ "u-boot.bin" ];
  };

  ubootRaspberryPi3_64bit = buildUBoot {
    defconfig = "rpi_3_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];
    filesToInstall = [ "u-boot.bin" ];
  };

  ubootRaspberryPi4_32bit = buildUBoot {
    defconfig = "rpi_4_32b_defconfig";
    extraMeta.platforms = [ "armv7l-linux" ];
    filesToInstall = [ "u-boot.bin" ];
  };

  ubootRaspberryPi4_64bit = buildUBoot {
    defconfig = "rpi_4_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];
    filesToInstall = [ "u-boot.bin" ];
  };

  ubootRaspberryPiAarch64 = buildUBoot {
    defconfig = "rpi_arm64_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];
    filesToInstall = [ "u-boot.bin" ];
  };

  ubootRaspberryPiZero = buildUBoot {
    defconfig = "rpi_0_w_defconfig";
    extraMeta.platforms = [ "armv6l-linux" ];
    filesToInstall = [ "u-boot.bin" ];
  };

  ubootRock3C = buildUBoot {
    strictDeps = true;

    env = {
      BL31 = "${armTrustedFirmwareRK3568}/bl31.elf";
      ROCKCHIP_TPL = rkbin.TPL_RK3566;
    };

    defconfig = "rock-3c-rk3566_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];

    filesToInstall = [
      "idbloader.img"
      "idbloader-spi.img"
      "u-boot.itb"
      "u-boot-rockchip.bin"
      "u-boot-rockchip-spi.bin"
    ];
  };

  ubootRock4CPlus = buildUBoot {
    env.BL31 = "${armTrustedFirmwareRK3399}/bl31.elf";
    defconfig = "rock-4c-plus-rk3399_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];

    filesToInstall = [
      "u-boot.itb"
      "idbloader.img"
    ];
  };

  ubootRock5ModelB = buildUBoot {
    env = {
      BL31 = "${armTrustedFirmwareRK3588}/bl31.elf";
      ROCKCHIP_TPL = rkbin.TPL_RK3588;
    };

    defconfig = "rock5b-rk3588_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];

    filesToInstall = [
      "u-boot.itb"
      "idbloader.img"
      "u-boot-rockchip.bin"
      "u-boot-rockchip-spi.bin"
    ];
  };

  ubootRock5ModelC = buildUBoot {
    env = {
      BL31 = "${armTrustedFirmwareRK3588}/bl31.elf";
      ROCKCHIP_TPL = rkbin.TPL_RK3588;
    };

    defconfig = "rock-5c-rk3588s_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];

    filesToInstall = [
      "u-boot.itb"
      "idbloader.img"
      "u-boot-rockchip.bin"
    ];
  };

  ubootRock64 = buildUBoot {
    env.BL31 = "${armTrustedFirmwareRK3328}/bl31.elf";
    defconfig = "rock64-rk3328_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];

    filesToInstall = [
      "u-boot.itb"
      "idbloader.img"
      "u-boot-rockchip.bin"
    ];
  };

  ubootRock64v2 = buildUBoot {
    env.BL31 = "${armTrustedFirmwareRK3328}/bl31.elf";
    defconfig = "rock64-rk3328_defconfig";

    extraMeta.longDescription = ''
      Boot loader for the Pine64 Rock64 V2.

      A special build with much lower memory frequency (666 vs 1600 MT/s) which
      makes ROCK64 V2 boards stable. This is necessary because the DDR3 routing
      on that revision is marginal and not unconditionally stable at the specified
      frequency. If your ROCK64 is unstable you can try this u-boot variant to
      see if it works better for you. The only disadvantage is lowered memory
      bandwidth.
    '';

    extraMeta.platforms = [ "aarch64-linux" ];

    filesToInstall = [
      "u-boot.itb"
      "idbloader.img"
      "u-boot-rockchip.bin"
    ];

    prePatch = ''
      substituteInPlace arch/arm/dts/rk3328-rock64-u-boot.dtsi \
        --replace rk3328-sdram-lpddr3-1600.dtsi rk3328-sdram-lpddr3-666.dtsi
    '';
  };

  ubootRockPi4 = buildUBoot {
    env.BL31 = "${armTrustedFirmwareRK3399}/bl31.elf";
    defconfig = "rock-pi-4-rk3399_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];

    filesToInstall = [
      "u-boot.itb"
      "idbloader.img"
    ];
  };

  ubootRockPiE = buildUBoot {
    env.BL31 = "${armTrustedFirmwareRK3328}/bl31.elf";
    defconfig = "rock-pi-e-rk3328_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];

    filesToInstall = [
      "u-boot.itb"
      "idbloader.img"
      "u-boot-rockchip.bin"
    ];
  };

  ubootRockPro64 = buildUBoot {
    env.BL31 = "${armTrustedFirmwareRK3399}/bl31.elf";
    defconfig = "rockpro64-rk3399_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];

    filesToInstall = [
      "u-boot.itb"
      "idbloader.img"
    ];
  };

  ubootSheevaplug = buildUBoot {
    defconfig = "sheevaplug_defconfig";

    extraMeta = {
      broken = true; # too big, exceeds partition size
      platforms = [ "armv5tel-linux" ];
    };

    filesToInstall = [ "u-boot.kwb" ];
  };

  ubootSopine = buildUBoot {
    env = {
      BL31 = "${armTrustedFirmwareAllwinner}/bl31.bin";
      SCP = "/dev/null";
    };

    defconfig = "sopine_baseboard_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];
    filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
  };

  ubootTools = buildUBoot {
    outputs = [
      "out"
      "man"
    ];

    postInstall = ''
      installManPage doc/*.1

      # from u-boot's tools/env/README:
      # "You should then create a symlink from fw_setenv to fw_printenv. They
      # use the same program and its function depends on its basename."
      ln -s $out/bin/fw_printenv $out/bin/fw_setenv
    '';

    crossTools = true;
    defconfig = "tools-only_defconfig";
    dontStrip = false;

    extraMakeFlags = [
      "HOST_TOOLS_ALL=y"
      "NO_SDL=1"
      "cross_tools"
      "envtools"
    ];

    extraMeta.platforms = lib.platforms.linux;

    filesToInstall = [
      "tools/dumpimage"
      "tools/fdt_add_pubkey"
      "tools/fdtgrep"
      "tools/kwboot"
      "tools/mkeficapsule"
      "tools/mkenvimage"
      "tools/mkimage"
      "tools/env/fw_printenv"
      "tools/mkeficapsule"
    ];

    hardeningDisable = [ ];
    installDir = "$out/bin";

    pythonScriptsToInstall = {
      "tools/efivar.py" = (python3.withPackages (ps: [ ps.pyopenssl ]));
    };
  };

  ubootTuringRK1 = buildUBoot {
    env = {
      BL31 = "${armTrustedFirmwareRK3588}/bl31.elf";
      ROCKCHIP_TPL = rkbin.TPL_RK3588;
    };

    defconfig = "turing-rk1-rk3588_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];

    filesToInstall = [
      "u-boot.itb"
      "idbloader.img"
      "u-boot-rockchip.bin"
    ];
  };

  ubootUtilite = buildUBoot {
    buildFlags = [ "u-boot-with-nand-spl.imx" ];
    defconfig = "cm_fx6_defconfig";

    extraConfig = ''
      CONFIG_CMD_SETEXPR=y
    '';

    extraMeta.longDescription = ''
      Boot loader for the CompuLab CM-FX6.

      Flashing instructions:
      ```
      sata init; load sata 0 $loadaddr u-boot-with-nand-spl.imx
      sf probe; sf update $loadaddr 0 80000
      ```
    '';

    extraMeta.platforms = [ "armv7l-linux" ];
    filesToInstall = [ "u-boot-with-nand-spl.imx" ];
  };

  ubootVisionFive2 = buildUBoot {
    env.OPENSBI = "${opensbi}/share/opensbi/lp64/generic/firmware/fw_dynamic.bin";
    defconfig = "starfive_visionfive2_defconfig";
    extraMeta.platforms = [ "riscv64-linux" ];

    filesToInstall = [
      "spl/u-boot-spl.bin.normal.out"
      "u-boot.itb"
    ];
  };

  ubootWandboard = buildUBoot {
    defconfig = "wandboard_defconfig";
    extraMeta.platforms = [ "armv7l-linux" ];

    filesToInstall = [
      "u-boot.img"
      "SPL"
    ];
  };
}
