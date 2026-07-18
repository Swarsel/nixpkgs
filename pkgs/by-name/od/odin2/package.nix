{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cmake,
  copyDesktopItems,
  freetype,
  gcc-unwrapped,
  libGL,
  libjack2,
  libx11,
  libxcursor,
  libxext,
  libxinerama,
  libxrandr,
  lv2,
  makeDesktopItem,
  nix-update-script,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "odin2";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "TheWaveWarden";
    repo = "odin2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-j/rZvBNBTDo2vwESXbGIXR89PHOI1HK8hvzV7y6dJHI=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    copyDesktopItems
  ];

  buildInputs = [
    alsa-lib
    freetype
    libjack2
    lv2
    libx11
    libxcursor
    libxext
    libxinerama
    libxrandr
    libGL
  ];

  cmakeFlags = [
    "-DCMAKE_AR=${gcc-unwrapped}/bin/gcc-ar"
    "-DCMAKE_RANLIB=${gcc-unwrapped}/bin/gcc-ranlib"
    "-DCMAKE_NM=${gcc-unwrapped}/bin/gcc-nm"
  ];

  # JUCE dlopen's these at runtime, crashes without them
  env.NIX_LDFLAGS = toString [
    "-lX11"
    "-lXext"
    "-lXcursor"
    "-lXinerama"
    "-lXrandr"
  ];

  # JUCE wants to write to $HOME/.{lv2,vst3}
  preConfigure = ''
    export HOME="$TMPDIR"
  '';

  installPhase = ''
    mkdir -p $out/bin $out/lib/vst3 $out/lib/lv2 $out/lib/clap $out/share/icons/hicolor/512x512/apps
    cd Odin2_artefacts/Release
    cp Standalone/Odin2 $out/bin
    cp -r VST3/Odin2.vst3 $out/lib/vst3
    cp -r LV2/Odin2.lv2 $out/lib/lv2
    cp -r CLAP/Odin2.clap $out/lib/clap
    # There’s no application icon, so the vendor’s logo will have to do.
    cp $src/manual/graphics/logo.png $out/share/icons/hicolor/512x512/apps/odin2.png
    copyDesktopItems
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "AudioVideo"
        "Audio"
        "Midi"
        "Music"
      ];

      comment = "Odin 2 Free Synthesizer";
      dbusActivatable = false;
      desktopName = "Odin 2";
      exec = "Odin2";
      icon = "odin2";
      name = "Odin2";
      startupNotify = true;
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Odin 2 Synthesizer Plugin";
    homepage = "https://thewavewarden.com/odin2";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ magnetophon ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "Odin2";
  };
})
