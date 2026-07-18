{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  fftwFloat,
  freetype,
  libGL,
  libx11,
  libxcursor,
  libxext,
  libxrender,
  lv2,
  meson,
  ninja,
  pkg-config,
  buildLV2 ? true,
  buildVST2 ? true,
  buildVST3 ? true,
  # empty means build all available plugins
  plugins ? [ ],
}:

let
  rpathLibs = [
    fftwFloat
  ];

  mesonPlugins = lib.mesonOption "plugins" "[${lib.concatMapStringsSep "," (x: "\"${x}\"") plugins}]";
in
stdenv.mkDerivation {
  pname = "distrho-ports";
  version = "2021-03-15-unstable-2025-08-15";

  src = fetchFromGitHub {
    owner = "DISTRHO";
    repo = "DISTRHO-Ports";
    rev = "d3b62da2e83c69b0866af5bb2e29ac78dc8014cf";
    sha256 = "sha256-wlppmRTdgA/9wWqFp75UyDLYJOqzg1aY+w97wTgJ8lk=";
    fetchSubmodules = true;
  };

  postPatch = ''
    chmod +x scripts/*.sh
    patchShebangs scripts
  '';

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
  ];

  buildInputs = rpathLibs ++ [
    alsa-lib
    freetype
    libGL
    libx11
    libxcursor
    libxext
    libxrender
    lv2
  ];

  mesonFlags = [
    (lib.mesonBool "build-lv2" buildLV2)
    (lib.mesonBool "build-vst2" buildVST2)
    (lib.mesonBool "build-vst3" buildVST3)
  ]
  ++ lib.optional (plugins != [ ]) mesonPlugins;

  env.NIX_CFLAGS_COMPILE = toString [ "-fpermissive" ];

  postFixup =
    let
      files = [
        (lib.optionalString buildLV2 "$out/lib/lv2/vitalium.lv2/vitalium-lv2.so")
        (lib.optionalString buildVST2 "$out/lib/vst/vitalium.so")
        (lib.optionalString buildVST3 "$out/lib/vst3/vitalium.vst3/Contents/x86_64-linux/vitalium.so")
      ];
    in
    lib.optionalString (lib.elem "vitalium" plugins || plugins == [ ]) ''
      for file in ${lib.concatMapStringsSep " \\\n" (x: "${x}") files}
      do
        patchelf --set-rpath "${lib.makeLibraryPath rpathLibs}:$(patchelf --print-rpath $file)" $file
      done
    '';

  meta = {
    description = "Linux audio plugins and LV2 ports";

    longDescription = ''
      You can override this package to only include some plugins like so:

      ```nix
      distrho-ports.override {
        plugins = [ "vitalium" "swankyamp" ];
      }
      ```

      Available plugins:
      - arctican-function
      - arctican-pilgrim
      - dexed
      - drowaudio-distortion
      - drowaudio-distortionshaper
      - drowaudio-flanger
      - drowaudio-reverb
      - drowaudio-tremolo
      - drumsynth
      - easySSP
      - eqinox
      - HiReSam
      - juce-opl
      - klangfalter
      - LUFSMeter
      - LUFSMeter-Multi
      - luftikus
      - obxd
      - pitchedDelay
      - refine
      - stereosourceseparation
      - swankyamp
      - tal-dub-3
      - tal-filter
      - tal-filter-2
      - tal-noisemaker
      - tal-reverb
      - tal-reverb-2
      - tal-reverb-3
      - tal-vocoder-2
      - temper
      - vex
      - vitalium
      - wolpertinger
    '';

    homepage = "http://distrho.sourceforge.net/ports";

    license = with lib.licenses; [
      gpl2Only
      gpl3Only
      gpl2Plus
      lgpl2Plus
      lgpl3Only
      mit
    ];

    maintainers = with lib.maintainers; [ bandithedoge ];
    platforms = lib.systems.inspect.patternLogicalAnd lib.systems.inspect.patterns.isLinux lib.systems.inspect.patterns.isx86;
  };
}
