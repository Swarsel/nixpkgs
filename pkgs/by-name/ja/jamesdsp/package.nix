{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  fetchpatch,
  glibmm,
  gst_all_1,
  kdePackages,
  libarchive,
  makeDesktopItem,
  pipewire,
  pkg-config,
  pulseaudio,
  usePipewire ? true,
  usePulseaudio ? false,
}:

assert lib.asserts.assertMsg (
  usePipewire != usePulseaudio
) "You need to enable one and only one of pulseaudio or pipewire support";

stdenv.mkDerivation (finalAttrs: {
  pname = "jamesdsp";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "Audio4Linux";
    repo = "JDSP4Linux";
    tag = finalAttrs.version;
    hash = "sha256-eVndqIqJ3DRceuFMT++g2riXq0CL5r+TWbvzvaYIfZ8=";
    fetchSubmodules = true;
  };

  patches = [
    (fetchpatch {
      hash = "sha256-RtVKlw2ca8An4FodeD0RN95z9yHDHBgAxsEwLAmW7co=";
      name = "fix-build-with-new-pipewire.patch";
      url = "https://github.com/Audio4Linux/JDSP4Linux/pull/241.patch";
    })
    ./fix-build-on-qt6_9.diff
  ];

  nativeBuildInputs = [
    kdePackages.qmake
    pkg-config
    copyDesktopItems
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = [
    glibmm
    libarchive
    kdePackages.qtbase
    kdePackages.qtsvg
    kdePackages.qtwayland
  ]
  ++ lib.optionals usePipewire [
    pipewire
  ]
  ++ lib.optionals usePulseaudio [
    pulseaudio
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gstreamer
  ];

  # https://github.com/Audio4Linux/JDSP4Linux/issues/228
  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error=incompatible-pointer-types"
    "-Wno-error=implicit-int"
    "-Wno-error=implicit-function-declaration"
  ];

  postInstall = ''
    install -D resources/icons/icon.png $out/share/icons/hicolor/512x512/apps/jamesdsp.png
    install -D resources/icons/icon.svg $out/share/icons/hicolor/scalable/apps/jamesdsp.svg
  '';

  preFixup = lib.optionalString usePulseaudio ''
    qtWrapperArgs+=(--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0")
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "AudioVideo"
        "Audio"
      ];

      comment = "JamesDSP for Linux";
      desktopName = "JamesDSP";
      exec = "jamesdsp";
      genericName = "Audio effects processor";
      icon = "jamesdsp";

      keywords = [
        "equalizer"
        "audio"
        "effect"
      ];

      name = "jamesdsp";
      startupNotify = false;
    })
  ];

  qmakeFlags = lib.optionals usePulseaudio [ "CONFIG+=USE_PULSEAUDIO" ];

  meta = {
    description = "Audio effect processor for PipeWire clients";
    homepage = "https://github.com/Audio4Linux/JDSP4Linux";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      pasqui23
      wineee
    ];

    platforms = lib.platforms.linux;
    mainProgram = "jamesdsp";
    broken = (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64);
  };
})
