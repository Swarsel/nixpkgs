{
  lib,
  stdenv,
  fetchzip,
  fixDarwinDylibNames,
  libusb1,
  pkg-config,
  systemdMinimal,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libusbsio";
  version = "2.1.11";

  src = fetchzip {
    url = "https://www.nxp.com/downloads/en/libraries/libusbsio-${finalAttrs.version}-src.zip";
    sha256 = "sha256-qgoeaGWTWdTk5XpJwoauckEQlqB9lp5x2+TN09vQttI=";
  };

  postPatch = ''
    rm -r bin/*
  '';

  nativeBuildInputs = [
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    fixDarwinDylibNames
  ];

  buildInputs = [
    libusb1
  ]

  ++ lib.optionals stdenv.hostPlatform.isLinux [
    systemdMinimal # libudev
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "BINDIR="
  ];

  installPhase = ''
    runHook preInstall
    install -D bin/libusbsio${stdenv.hostPlatform.extensions.sharedLibrary} $out/lib/libusbsio${stdenv.hostPlatform.extensions.sharedLibrary}
    runHook postInstall
  '';

  meta = {
    description = "Library for communicating with devices connected via the USB bridge on LPC-Link2 and MCU-Link debug probes on supported NXP microcontroller evaluation boards";
    homepage = "https://www.nxp.com/design/software/development-software/library-for-windows-macos-and-ubuntu-linux:LIBUSBSIO";
    license = lib.licenses.bsd3;

    maintainers = [
    ];

    platforms = lib.platforms.all;
  };
})
