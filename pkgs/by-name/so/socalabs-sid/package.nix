{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cmake,
  copyDesktopItems,
  curl,
  expat,
  freetype,
  imagemagick,
  lerc,
  libGL,
  libdatrie,
  libepoxy,
  libjack2,
  libselinux,
  libsepol,
  libsysprof-capture,
  libthai,
  libx11,
  libxcomposite,
  libxcursor,
  libxdmcp,
  libxinerama,
  libxkbcommon,
  libxrandr,
  libxtst,
  makeDesktopItem,
  ninja,
  pcre2,
  pkg-config,
  sqlite,
  util-linux,
  webkitgtk_4_1,
  xvfb,
  # Disable VST building by default, since NixOS doesn't have a VST license
  enableVST2 ? false,
}:
stdenv.mkDerivation {
  pname = "socalabs-sid";
  version = "1.1.0";

  src =
    (fetchFromGitHub {
      owner = "FigBug";
      repo = "SID";
      rev = "bb826fdea39da0804c53d81d35bea29aeff4436d";
      hash = "sha256-6IStysItOS7EltTCqdyo9vrsnSA1YYoN4y8Bjv1fhNk=";
      fetchSubmodules = true;
    }).overrideAttrs
      (_: {
        GIT_CONFIG_COUNT = 1;
        GIT_CONFIG_KEY_0 = "url.https://github.com/.insteadOf";
        GIT_CONFIG_VALUE_0 = "git@github.com:";
      });

  strictDeps = true;

  nativeBuildInputs = [
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
    xvfb
    libGL
    libjack2
    libsysprof-capture
    libselinux
    libsepol
    libthai
    libxkbcommon
    libdatrie
    libepoxy
    lerc
    freetype
    curl
    webkitgtk_4_1
    pcre2
    util-linux
    sqlite
    expat
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
    # build takes 10 years without this set
    HOME=(mktemp -d)

    cd ../Builds/ninja-gcc
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/vst3 $out/lib/lv2 $out/bin

    ${lib.optionalString enableVST2 ''
      mkdir -p $out/lib/vst
      cp -r SID_artefacts/Release/VST/libSID.so $out/lib/vst
    ''}

    cp -r SID_artefacts/Release/LV2/SID.lv2 $out/lib/lv2
    cp -r SID_artefacts/Release/VST3/SID.vst3 $out/lib/vst3

    install -Dm755 SID_artefacts/Release/Standalone/SID $out/bin

    mkdir -p $out/share/icons/hicolor/256x256/apps
    magick $src/plugin/Resources/icon.png -resize 256x256 $out/share/icons/hicolor/256x256/apps/SID.png

    runHook postInstall
  '';

  cmakeBuildType = "Release";

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Audio"
        "AudioVideo"
      ];

      comment = "Socalabs Commodore 64 SID Emulation Plugin (Standalone)";
      desktopName = "Socalabs SID";
      exec = "SID";
      icon = "SID";
      name = "socalabs-sid";
      type = "Application";
    })
  ];

  patchPhase = ''
    substituteInPlace CMakeLists.txt \
    --replace-fail 'FORMATS Standalone VST VST3 AU LV2' 'FORMATS Standalone ${lib.optionalString enableVST2 "VST"} VST3 LV2'

    # we need to patch JUCE itself to enable jack MIDI support
    # please https://github.com/juce-framework/JUCE/issues/952
    # TODO: remove when juce updates :D
    substituteInPlace modules/juce/modules/juce_audio_devices/native/juce_Midi_linux.cpp \
    --replace-fail "port = client.createPort (portName, forInput, false);" "port = client.createPort (portName, forInput, true);"
  '';

  meta = {
    description = "Socalabs Commodore 64 SID Emulation Plugin";
    homepage = "https://socalabs.com/synths/commodore-64-sid/";
    license = [ lib.licenses.gpl3 ] ++ lib.optional enableVST2 lib.licenses.unfree;
    maintainers = [ lib.maintainers.l1npengtul ];
    platforms = lib.platforms.linux;
    mainProgram = "SID";
  };
}
