{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cmake,
  flatbuffers,
  libjpeg_turbo,
  linalg,
  lunasvg,
  mbedtls,
  mdns,
  nanopb,
  pipewire,
  pkg-config,
  plutovg,
  qmqtt,
  qt6Packages,
  sdbus-cpp_2,
  stb,
  xz,
}:

let
  inherit (lib)
    cmakeBool
    ;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "hyperhdr";
  version = "21.0.0.0";

  src = fetchFromGitHub {
    owner = "awawa-dev";
    repo = "HyperHDR";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CSggawgUPkpeADc8VXs5FA+ubZAtrtTu0qYgIWA0V/c=";
  };

  patches = [
    # Allow completely unvendoring hyperhdr
    # This can be removed on the next hyperhdr release
    ./unvendor.patch
  ];

  postPatch = ''
    substituteInPlace sources/sound-capture/linux/SoundCaptureLinux.cpp \
      --replace-fail "libasound.so.2" "${lib.getLib alsa-lib}/lib/libasound.so.2"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    alsa-lib
    flatbuffers
    libjpeg_turbo
    linalg
    lunasvg
    mbedtls
    mdns
    nanopb
    pipewire
    plutovg
    qmqtt
    qt6Packages.qtbase
    qt6Packages.qtserialport
    sdbus-cpp_2
    stb
    xz
  ];

  cmakeFlags = [
    "-DPLATFORM=linux"
    (cmakeBool "USE_SYSTEM_FLATBUFFERS_LIBS" true)
    (cmakeBool "USE_SYSTEM_LUNASVG_LIBS" true)
    (cmakeBool "USE_SYSTEM_MBEDTLS_LIBS" true)
    (cmakeBool "USE_SYSTEM_MQTT_LIBS" true)
    (cmakeBool "USE_SYSTEM_NANOPB_LIBS" true)
    (cmakeBool "USE_SYSTEM_SDBUS_CPP_LIBS" true)
    (cmakeBool "USE_SYSTEM_STB_LIBS" true)
  ];

  meta = {
    description = "Highly optimized open source ambient lighting implementation based on modern digital video and audio stream analysis for Windows, macOS and Linux (x86 and Raspberry Pi / ARM";
    homepage = "https://github.com/awawa-dev/HyperHDR";
    changelog = "https://github.com/awawa-dev/HyperHDR/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      hexa
      eymeric
    ];

    platforms = lib.platforms.linux;
    mainProgram = "hyperhdr";
  };
})
