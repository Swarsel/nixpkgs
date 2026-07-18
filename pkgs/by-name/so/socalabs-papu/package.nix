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
  imagemagick,
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
  nix-update-script,
  pkg-config,
  writableTmpDirAsHomeHook,
  xvfb,
  # Disable VST building by default, since its unfree
  enableVST2 ? false,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "socalabs-papu";
  version = "1.2.5";

  src = fetchFromGitHub {
    owner = "FigBug";
    repo = "PAPU";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gR04DnXMxGIjlUqxBaneljfzKyzTOrhxiW//rOAQhj8=";
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
    imagemagick
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
      cp -r PAPU_artefacts/Release/VST/libPAPU.so $out/lib/vst
    ''}

    cp -r PAPU_artefacts/Release/LV2/PAPU.lv2 $out/lib/lv2
    cp -r PAPU_artefacts/Release/VST3/PAPU.vst3 $out/lib/vst3

    install -Dm555 PAPU_artefacts/Release/Standalone/PAPU $out/bin

    mkdir -p $out/share/icons/hicolor/256x256/apps
    magick $src/plugin/Resources/icon.png -resize 256x256 $out/share/icons/hicolor/256x256/apps/PAPU.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Audio"
        "AudioVideo"
      ];

      comment = "Socalabs Nintendo Gameboy PAPU Emulation Plugin (Standalone)";
      desktopName = "Socalabs PAPU";
      exec = "PAPU";
      icon = "PAPU";
      name = "socalabs-papu";
      type = "Application";
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Socalabs Nintendo Gameboy PAPU Emulation Plugin";
    homepage = "https://socalabs.com/synths/papu/";
    license = [ lib.licenses.gpl2 ] ++ lib.optional enableVST2 lib.licenses.unfree;
    maintainers = [ lib.maintainers.l1npengtul ];
    platforms = lib.platforms.linux;
    mainProgram = "PAPU";
  };
})
