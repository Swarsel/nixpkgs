{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  autoPatchelfHook,
  copyDesktopItems,
  curl,
  fetchzip,
  freetype,
  imagemagick,
  libGL,
  libice,
  libjack2,
  libsm,
  libx11,
  makeBinaryWrapper,
  makeDesktopItem,
  zenity,
}:
let
  icon = fetchurl {
    hash = "sha256-NZ/AQ2gjBXUPUj3ITbowD7HuxRmEDuATOWidLqLNrww=";
    url = "https://vital.audio/images/apple_touch_icon.png";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "vital";
  version = "1.5.5";

  src = fetchzip {
    url = "https://builds.vital.audio/VitalAudio/vital/${
      builtins.replaceStrings [ "." ] [ "_" ] finalAttrs.version
    }/VitalInstaller.zip";

    hash = "sha256-hCwXSUiBB0YpQ1oN6adLprwAoel6f72tBG5fEb61OCI=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeBinaryWrapper
    copyDesktopItems
    imagemagick
  ];

  buildInputs = [
    alsa-lib
    (lib.getLib stdenv.cc.cc)
    libGL
    libsm
    libice
    libx11
    freetype
    libjack2
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons/hicolor/128x128/apps
    magick ${icon} -resize 128x128 $out/share/icons/hicolor/128x128/apps/Vital.png

    # copy each output to its destination (individually)
    mkdir -p $out/{bin,lib/{clap,vst,vst3}}
    for f in bin/Vital lib/{clap/Vital.clap,vst/Vital.so,vst3/Vital.vst3}; do
      cp -r $f $out/$f
    done

    wrapProgram $out/bin/Vital \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          curl
          libjack2
        ]
      }" \
      --prefix PATH : "${
        lib.makeBinPath [
          zenity
        ]
      }"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Audio"
        "AudioVideo"
      ];

      comment = "Spectral warping wavetable synth";
      desktopName = "Vital";
      exec = "Vital";
      icon = "Vital";
      name = "vital";
      type = "Application";
    })
  ];

  dontBuild = true;

  meta = {
    description = "Spectral warping wavetable synth";
    homepage = "https://vital.audio/";
    license = lib.licenses.unfree; # https://vital.audio/eula/
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];

    maintainers = with lib.maintainers; [
      PowerUser64
      l1npengtul
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "Vital";
  };
})
