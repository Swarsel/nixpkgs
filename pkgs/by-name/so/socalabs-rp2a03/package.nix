{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cmake,
  copyDesktopItems,
  curl,
  expat,
  fontconfig,
  freetype,
  libGL,
  libjack2,
  libx11,
  libxcomposite,
  libxcursor,
  libxdmcp,
  libxext,
  libxinerama,
  libxrandr,
  libxtst,
  makeDesktopItem,
  ninja,
  pkg-config,
  writableTmpDirAsHomeHook,
  xvfb,
  # Disable VST building by default, since its unfree
  enableVST2 ? false,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "socalabs-rp2a03";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "FigBug";
    repo = "RP2A03";
    rev = "dd90863aed05afe110a5302b5eff4b5144f28d4c";
    hash = "sha256-arEM6mq2oJATj87pyPZ+ZNlLd3kL//BNO5y2SFf+nSo=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
    --replace-fail 'FORMATS Standalone VST VST3 AU LV2' 'FORMATS Standalone ${lib.optionalString enableVST2 "VST"} VST3 LV2'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    writableTmpDirAsHomeHook
    cmake
    pkg-config
    copyDesktopItems
    ninja
  ];

  buildInputs = [
    alsa-lib
    libx11
    libxcomposite
    libxcursor
    libxinerama
    libxrandr
    libxtst
    libxdmcp
    libxext
    xvfb
    libGL
    libjack2
    freetype
    fontconfig
    expat
    curl
  ];

  cmakeFlags = [
    (lib.cmakeBool "JUCE_COPY_PLUGIN_AFTER_BUILD" false)
    "--preset ninja-gcc"
  ];

  env.NIX_LDFLAGS = toString [
    "-lX11"
    "-lXext"
    "-lXcomposite"
    "-lXcursor"
    "-lXinerama"
    "-lXrandr"
    "-lXtst"
    "-lXdmcp"
  ];

  preBuild = ''
    cd ../Builds/ninja-gcc
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/vst3 $out/lib/lv2 $out/bin

    ${lib.optionalString enableVST2 ''
      mkdir -p $out/lib/vst
      cp -r RP2A03_artefacts/Release/VST/libRP2A03.so $out/lib/vst
    ''}

    cp -r RP2A03_artefacts/Release/LV2/RP2A03.lv2 $out/lib/lv2
    cp -r RP2A03_artefacts/Release/VST3/RP2A03.vst3 $out/lib/vst3

    install -Dm555 RP2A03_artefacts/Release/Standalone/RP2A03 $out/bin

    install -Dm444 $src/plugin/Resources/logo.png $out/share/pixmaps/RP2A03.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Audio"
        "AudioVideo"
      ];

      comment = "Socalabs NES Ricoh 2A03 Emulation Plugin (Standalone)";
      desktopName = "Socalabs RP2A03";
      exec = "RP2A03";
      icon = "RP2A03";
      name = "socalabs-rp2a03";
      type = "Application";
    })
  ];

  meta = {
    description = "Socalabs NES Ricoh 2A03 Emulation Plugin";
    homepage = "https://socalabs.com/synths/rp2a03/";
    license = [ lib.licenses.lgpl21 ] ++ lib.optional enableVST2 lib.licenses.unfree;
    maintainers = [ lib.maintainers.l1npengtul ];
    platforms = lib.platforms.linux;
    mainProgram = "RP2A03";
  };
})
