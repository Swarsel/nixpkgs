{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  at-spi2-core,
  cmake,
  curl,
  dbus,
  fftwFloat,
  freetype,
  gtk3,
  libepoxy,
  libjack2,
  libpthread-stubs,
  libx11,
  libxdmcp,
  libxkbcommon,
  lv2,
  pkg-config,
}:

let
  pname = "HybridReverb2";
  version = "2.1.2-unstable-2021-12-19";
  rev = "2fc44c419f90133b3fcde71820212b5f281a0ad2";
  owner = "jpcima";
  DBversion = "1.0.0";
in

stdenv.mkDerivation rec {
  inherit pname version;

  src = fetchFromGitHub {
    inherit owner;
    repo = "HybridReverb2";
    rev = rev;
    hash = "sha256-+uwTKHQ3nIWKbBCPtf/axvyW6MU0gemVtd2ZqqiT/w0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs = [
    lv2
    alsa-lib
    libjack2
    freetype
    libx11
    gtk3
    libpthread-stubs
    libxdmcp
    libxkbcommon
    libepoxy
    at-spi2-core
    dbus
    curl
    fftwFloat
  ];

  cmakeFlags = [
    "-DHybridReverb2_AdvancedJackStandalone=ON"
    "-DHybridReverb2_UseLocalDatabase=ON"
  ];

  postInstall = ''
    mkdir -p $out/share/HybridReverb2/
    cp  -r ${impulseDB}/* $out/share/HybridReverb2/
  '';

  enableParallelBuilding = true;

  impulseDB = fetchFromGitHub {
    inherit owner;
    repo = "HybridReverb2-impulse-response-database";
    rev = "v${DBversion}";
    sha256 = "sha256-PyGrMNhrL2cRjb2UPPwEaJ6vZBV2sDG1mKFCNdfqjsI=";
  };

  meta = {
    description = "Reverb effect using hybrid impulse convolution";
    homepage = "https://github.com/jpcima/HybridReverb2";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.linux;
    mainProgram = "HybridReverb2";
  };
}
