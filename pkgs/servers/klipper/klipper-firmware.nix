args@{
  lib,
  stdenv,
  avrdude,
  bintools-unwrapped,
  gcc-arm-embedded,
  klipper,
  klipper-firmware,
  klipper-flash,
  libffi,
  libusb1,
  pkg-config,
  pkgsCross,
  python3,
  stm32flash,
  wxwidgets_3_2,
  firmwareConfig ? ./simulator.cfg,
  mcu ? "mcu",
}:
# are used by flash scripts
# find those with `rg '\[\"lib'` inside of klipper repo
let
  needsBossac =
    let
      lines = lib.strings.splitString "\n" (builtins.readFile firmwareConfig);
    in
    builtins.any (line: builtins.match "[^#\r\n]*CONFIG_MACH_ATSAMD?=y.*" line != null) lines;
  flashBinaries = [
    "lib/hidflash/hid-flash"
    "lib/rp2040_flash/rp2040_flash"
  ]
  ++ lib.optional needsBossac "lib/bossac/bin/bossac";
in
stdenv.mkDerivation {
  pname = "klipper-firmware-${mcu}";
  version = klipper.version;
  src = klipper.src;

  postPatch = ''
    patchShebangs .
  '';

  nativeBuildInputs = [
    python3
    pkgsCross.avr.stdenv.cc
    gcc-arm-embedded
    bintools-unwrapped
    libffi
    libusb1
    avrdude
    stm32flash
    pkg-config
  ]
  ++ lib.optional needsBossac wxwidgets_3_2;

  makeFlags = [
    "V=1"
    "WXVERSION=3.2"
  ];

  postBuild = ''
    # build flash binaries
    ${with builtins; concatStringsSep "\n" (map (path: "make ${path} $out/bin/ || true") flashBinaries)}
  '';

  installPhase = ''
    mkdir -p $out
    cp ./.config $out/config
    cp out/klipper.bin $out/ || true
    cp out/klipper.elf $out/ || true
    cp out/klipper.elf.hex $out/ || true
    cp out/klipper.uf2 $out/ || true

    mkdir -p $out/lib/

    ${
      with builtins;
      concatStringsSep "\n" (
        map (path: ''
          if [ -e ${path} ]; then
            mkdir -p $out/$(dirname ${path})
            cp -r ${path} $out/$(dirname ${path})
          fi
        '') flashBinaries
      )
    }
    rmdir $out/lib 2>/dev/null || echo "Flash binaries exist, not cleaning up lib/"

  '';

  configurePhase = ''
    cp ${firmwareConfig} ./.config
    chmod +w ./.config
    echo qy | { make menuconfig >/dev/null || true; }
    if ! diff ${firmwareConfig} ./.config; then
      echo " !!! Klipper KConfig has changed. Please run klipper-genconf to update your configuration."
    fi
  '';

  dontFixup = true;

  passthru = {
    makeFlasher =
      {
        canbusDevice ? null,
        canbusNetwork ? null,
        flashDevice ? null,
      }:
      klipper-flash.override {
        inherit
          klipper
          firmwareConfig
          mcu
          flashDevice
          canbusNetwork
          canbusDevice
          ;

        klipper-firmware = klipper-firmware.override args;
      };
  };

  meta = {
    inherit (klipper.meta) homepage license;
    description = "Firmware part of Klipper";

    maintainers = with lib.maintainers; [
      vtuan10
      cab404
    ];

    platforms = lib.platforms.linux;
  };
}
