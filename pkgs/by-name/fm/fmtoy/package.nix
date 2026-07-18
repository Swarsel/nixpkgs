{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cmake,
  libjack2,
  libvgm,
  pkg-config,
  unstableGitUpdater,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fmtoy";
  version = "0-unstable-2024-12-15";

  src = fetchFromGitHub {
    owner = "vampirefrog";
    repo = "fmtoy";
    rev = "6858fc8ad3171df2c9b90cb1e62719af9fc4f7c2";
    hash = "sha256-OiPKtFPlTxdMNSTLJXcXZkqjzUiGQKXSF2udHePBpho=";
    fetchSubmodules = true;
  };

  patches = [
    # Build against our libvgm
    ./2001-Build-against-system-installed-libvgm.patch
  ];

  postPatch =
    # We don't want to use this libvgm, make sure it can't be referenced by accident
    ''
      rm -r libvgm
    ''
    # Fix cross by using pkg-config for hostPlatform packages
    + ''
      substituteInPlace Makefile \
        --replace-fail 'pkg-config' "$PKG_CONFIG"
    '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    libjack2
    (libvgm.override {
      emulators = [
        "YM2151_ALL"
        "YM2203_ALL"
        "YM2608_ALL"
        "YM2610_ALL"
        "YM2612_ALL"
        "YM3812_ALL"
        "YMF262_ALL"
      ];

      # Don't need these
      enableAudio = false;
      # Only enable free cores that we actually use
      enableEmulation = true;
      enableLibplayer = false;
      enableTools = false;
      withAllEmulators = false;
    })
    zlib
  ];

  buildFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "CXX=${stdenv.cc.targetPrefix}c++"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 fmtoy_jack $out/bin/fmtoy_jack

    runHook postInstall
  '';

  dontUseCmakeConfigure = true;
  enableParallelBuilding = true;

  passthru = {
    updateScript = unstableGitUpdater { };
  };

  meta = {
    description = "FM synthesiser based on emulated Yamaha YM chips (OPL, OPM and OPN series)";
    homepage = "https://github.com/vampirefrog/fmtoy";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ OPNA2608 ];
    platforms = lib.platforms.linux;
    mainProgram = "fmtoy_jack";
  };
})
