{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cmake,
  copyDesktopItems,
  fontconfig,
  freetype,
  glew,
  glfw,
  glib,
  jansson,
  jq,
  juce,
  libarchive,
  libdeflate,
  libjack2,
  libpulseaudio,
  libsamplerate,
  libsoup_3,
  libwebp,
  libx11,
  libxcomposite,
  libxcursor,
  libxext,
  libxinerama,
  libxrandr,
  libxrender,
  makeDesktopItem,
  pkg-config,
  rtmidi,
  speexdsp,
  srcOnly,
  vcv-rack,
  xz,
  zstd,
  enableVCVRack ? false,
}:
let
  clapJuceExtensions = fetchFromGitHub {
    fetchSubmodules = true;
    hash = "sha256-Lx88nyEFjPLA5yh8rrqBdyZIxe/j0FgIHoyKcbjuuI4=";
    owner = "free-audio";
    repo = "clap-juce-extensions";
    rev = "645ed2fd0949d36639e3d63333f26136df6df769";
  };

  vcvRackSdk = srcOnly vcv-rack;
  pname = "airwin2rack";
  version = "2.13.0-unstable-2026-01-19";
in
stdenv.mkDerivation {
  inherit pname;
  inherit version;

  src = fetchFromGitHub {
    owner = "baconpaul";
    repo = "airwin2rack";
    rev = "ed3700c223be0fd5eddf6d57b66216fff8389c2c";
    hash = "sha256-JHARxie6y3mD/ZLEMGmfK8/b5GBcN/7lHpm7kI5BpTs=";
    fetchSubmodules = true;
  };

  patches = [
    ./juce-clap-juce-extensions-src-juce-cmakelists.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    copyDesktopItems
  ]
  ++ lib.optionals enableVCVRack [
    jq
    zstd
  ];

  buildInputs = [
    alsa-lib
    libx11
    libxcomposite
    libxcursor
    libxext
    libxinerama
    libxrandr
    libxrender
    fontconfig
    libjack2
    freetype
    glib
    libsoup_3
    libdeflate
    xz # liblzma
    libwebp
  ]
  ++ lib.optionals enableVCVRack [
    vcv-rack
    jansson
    glew
    glfw
    libarchive
    speexdsp
    libpulseaudio
    libsamplerate
    rtmidi
    zstd
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_JUCE_PLUGIN" true)
    (lib.cmakeBool "USE_JUCE_PROGRAMS" true)
  ]
  ++ lib.optionals enableVCVRack [
    (lib.cmakeBool "BUILD_RACK_PLUGIN" true)
    (lib.cmakeFeature "RACK_SDK_DIR" "${vcvRackSdk}")
  ];

  env.NIX_LDFLAGS = toString [
    "-lX11"
    "-lXext"
    "-lXcomposite"
    "-lXcursor"
    "-lXinerama"
    "-lXrandr"
    "-lXrender"
  ];

  preConfigure = lib.optionalString enableVCVRack "export RACK_DIR=${vcvRackSdk}";

  buildPhase = ''
    runHook preBuild
    cmake --build . --target awcons-products ${lib.optionalString enableVCVRack "build_plugin"} --parallel $NIX_BUILD_CORES
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/vst3 $out/lib/lv2 $out/lib/clap $out/bin

    cp -r "awcons-products/Airwindows Consolidated.vst3" $out/lib/vst3
    cp -r "awcons-products/Airwindows Consolidated.lv2" $out/lib/lv2
    install -Dm644 "awcons-products/Airwindows Consolidated.clap" -t $out/lib/clap

    install -Dm755 "awcons-products/Airwindows Consolidated" $out/bin/Airwindows\ Consolidated

    ${lib.optionalString enableVCVRack ''
      mkdir ../${pname}
      strip -s plugin.so
      mv plugin.so ../${pname}
      cd ..
      mv LICENSE.md ${pname}
      mv README.md ${pname}
      mv plugin.json ${pname}
      mv res ${pname}
      tar -c ${pname} | zstd -19 -o "${pname}-${version}-lin-x64.vcvplugin"
      # got the directory from arch wiki
      install -Dm755 "${pname}-${version}-lin-x64.vcvplugin" $out/usr/lib/vcvrack/plugins
    ''}

    runHook postInstall
  '';

  cmakeBuildType = "Release";

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Audio"
        "AudioVideo"
      ];

      comment = "Various Airwindows Plugins Consolidated (Standalone)";
      desktopName = "Airwindows Consolidated";
      exec = "Airwindows Consolidated";
      name = "Airwin2rack";
      type = "Application";
    })
  ];

  prePatch = ''
    ln -s ${juce.src} src-juce/juce
    ln -s ${clapJuceExtensions} src-juce/clap-juce-extensions
  '';

  meta = {
    description = "JUCE Plugin Version of Airwindows Consolidated";
    homepage = "https://github.com/baconpaul/airwin2rack";

    license =
      with lib.licenses;
      [ mit ]
      ++ lib.optional enableVCVRack [
        gpl3Plus
        cc-by-nc-40
        unfreeRedistributable
      ];

    maintainers = [ lib.maintainers.l1npengtul ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "Airwindows Consolidated";
  };
}
