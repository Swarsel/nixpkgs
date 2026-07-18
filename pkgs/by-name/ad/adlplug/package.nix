{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cmake,
  fmt,
  freetype,
  libjack2,
  liblo,
  libx11,
  libxcursor,
  libxext,
  libxinerama,
  libxrandr,
  pkg-config,
  unstableGitUpdater,
  type ? "ADL",
  # Enabling JACK requires a JACK server at runtime, no fallback mechanism
  withJack ? false,
}:

assert lib.assertOneOf "type" type [
  "ADL"
  "OPN"
];
let
  chip =
    {
      ADL = "OPL3";
      OPN = "OPN2";
    }
    .${type};
  mainProgram = "${type}plug";
in
stdenv.mkDerivation {
  pname = "${lib.strings.toLower type}plug";
  version = "1.0.2-unstable-2021-12-17";

  src = fetchFromGitHub {
    owner = "jpcima";
    repo = "ADLplug";
    rev = "a488abedf1783c61cb4f0caa689f1b01bf9aa17d";
    sha256 = "1a5zw0rglqgc5wq1n0s5bxx7y59dsg6qy02236fakl34bvbk60yz";
    fetchSubmodules = true;
  };

  patches = [
    # fix for CMake v4
    # https://github.com/jpcima/ADLplug/pull/100
    ./cmake-v4.patch
  ];

  # See https://github.com/NixOS/nixpkgs/issues/445447
  postPatch = ''
    substituteInPlace thirdparty/{libADLMIDI,libOPNMIDI}/CMakeLists.txt --replace-fail \
      'cmake_minimum_required (VERSION 3.2)' \
      'cmake_minimum_required (VERSION 3.10)'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    fmt
    liblo
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    freetype
    libx11
    libxrandr
    libxinerama
    libxext
    libxcursor
  ]
  ++ lib.optionals withJack [ libjack2 ];

  cmakeFlags = [
    (lib.cmakeFeature "ADLplug_CHIP" chip)
    (lib.cmakeBool "ADLplug_USE_SYSTEM_FMT" true)
    (lib.cmakeBool "ADLplug_Jack" withJack)
  ];

  env.NIX_LDFLAGS = toString (
    lib.optionals stdenv.hostPlatform.isDarwin [
      # Framework that JUCE needs which don't get linked properly
      "-framework CoreAudioKit"
      "-framework QuartzCore"
      "-framework AudioToolbox"
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      # JUCE dlopen's these at runtime
      "-lX11"
      "-lXext"
      "-lXcursor"
      "-lXinerama"
      "-lXrandr"
    ]
  );

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/{Applications,Library/Audio/Plug-Ins/{VST,Components}}

    mv $out/bin/${mainProgram}.app $out/Applications/
    ln -s $out/{Applications/${mainProgram}.app/Contents/MacOS,bin}/${mainProgram}

    mv vst2/${mainProgram}.vst $out/Library/Audio/Plug-Ins/VST/
    mv au/${mainProgram}.component $out/Library/Audio/Plug-Ins/Components/
  '';

  passthru.updateScript = unstableGitUpdater {
    tagFormat = "v*";
    tagPrefix = "v";
  };

  meta = {
    inherit mainProgram;
    description = "${chip} FM Chip Synthesizer";
    homepage = "https://github.com/jpcima/ADLplug";
    license = lib.licenses.boost;
    maintainers = with lib.maintainers; [ OPNA2608 ];
    platforms = lib.platforms.all;
  };
}
