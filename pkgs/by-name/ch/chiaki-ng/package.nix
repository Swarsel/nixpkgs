{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  cmake,
  curlFull,
  fetchpatch,
  ffmpeg,
  fftw,
  hidapi,
  json_c,
  kdePackages,
  lcms2,
  libdovi,
  libevdev,
  libopus,
  libplacebo,
  libunwind,
  miniupnpc,
  nanopb,
  pkg-config,
  protobuf,
  python3,
  shaderc,
  speexdsp,
  udev,
  vulkan-headers,
  vulkan-loader,
  xxhash,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chiaki-ng";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "streetpea";
    repo = "chiaki-ng";
    tag = "v${finalAttrs.version}";
    hash = "sha256-se60wu1rwk/w5QG+pFvdtKD+zsJQdOmBole2WY2KCxw=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.wrapQtAppsHook
    protobuf
    python3
    python3.pkgs.wrapPython
    python3.pkgs.protobuf
    python3.pkgs.setuptools
  ];

  buildInputs = [
    ffmpeg
    libopus
    kdePackages.qtbase
    kdePackages.qtmultimedia
    kdePackages.qtsvg
    kdePackages.qtdeclarative
    kdePackages.qtwayland
    kdePackages.qtwebengine
    protobuf
    SDL2
    curlFull
    hidapi
    json_c
    fftw
    miniupnpc
    nanopb
    libevdev
    udev
    speexdsp
    libplacebo
    vulkan-headers
    libunwind
    shaderc
    lcms2
    libdovi
    xxhash
  ];

  cmakeFlags = [
    "-Wno-dev"
    (lib.cmakeFeature "CHIAKI_USE_SYSTEM_CURL" "true")
  ];

  env.NIX_CFLAGS_COMPILE = "-std=gnu17";

  postInstall = ''
    install -Dm755 $src/scripts/psn-account-id.py $out/bin/psn-account-id
  '';

  postFixup = ''
    wrapPythonPrograms
  '';

  pythonPath = [
    python3.pkgs.requests
  ];

  qtWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${vulkan-loader}/lib"
  ];

  meta = {
    description = "Next-Generation of Chiaki (the open-source remote play client for PlayStation)";
    homepage = "https://streetpea.github.io/chiaki-ng/";
    # Includes OpenSSL linking exception that we currently have no way
    # to represent.
    #
    # See also: <https://github.com/spdx/license-list-XML/issues/939>
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ devusb ];
    platforms = lib.platforms.linux;
    mainProgram = "chiaki";
  };
})
