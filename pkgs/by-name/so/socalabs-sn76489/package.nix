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
  nix-update-script,
  pkg-config,
  writableTmpDirAsHomeHook,
  xvfb,
  # Disable VST building by default, since it is unfree
  enableVST2 ? false,
}:
let
  version = "1.1.5";
in
stdenv.mkDerivation {
  inherit version;
  pname = "socalabs-sn76489";

  src = fetchFromGitHub {
    owner = "FigBug";
    repo = "SN76489";
    tag = "v${version}";
    hash = "sha256-dQ697B0mhdIC0ltdY2EnErLNAGRKA6ARONX/kR3OLyI=";
    fetchSubmodules = true;

    preFetch = ''
      # can't clone using ssh
      export GIT_CONFIG_COUNT=1
      export GIT_CONFIG_KEY_0=url.https://github.com/.insteadOf
      export GIT_CONFIG_VALUE_0=git@github.com:
    '';
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
      cp -r SN76489_artefacts/Release/VST/libSN76489.so $out/lib/vst
    ''}

    cp -r SN76489_artefacts/Release/LV2/SN76489.lv2 $out/lib/lv2
    cp -r SN76489_artefacts/Release/VST3/SN76489.vst3 $out/lib/vst3

    install -Dm555 SN76489_artefacts/Release/Standalone/SN76489 $out/bin

    install -Dm444 $src/plugin/Resources/logo.png $out/share/pixmaps/SN76489.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Audio"
        "AudioVideo"
      ];

      comment = "Socalabs Texas Instruments SN76489 Emulation Plugin";
      desktopName = "Socalabs SN76489";
      exec = "SN76489";
      icon = "SN76489";
      name = "socalabs-sn76489";
      type = "Application";
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Socalabs Texas Instruments SN76489 Emulation Plugin";
    homepage = "https://socalabs.com/synths/sn76489/";
    license = [ lib.licenses.lgpl21 ] ++ lib.optional enableVST2 lib.licenses.unfree;
    maintainers = [ lib.maintainers.l1npengtul ];
    platforms = lib.platforms.linux;
    mainProgram = "SN76489";
  };
}
