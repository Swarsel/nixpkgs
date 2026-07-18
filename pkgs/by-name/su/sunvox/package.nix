{
  lib,
  stdenv,
  fetchurl,
  SDL2,
  alsa-lib,
  autoPatchelfHook,
  copyDesktopItems,
  fetchzip,
  imagemagick,
  libglvnd,
  libjack2,
  libx11,
  libxi,
  makeDesktopItem,
  makeWrapper,
}:
let
  platforms = {
    "aarch64-darwin" = "macos";
    "aarch64-linux" = "linux_arm64";
    "armv7l-linux" = "arm_armhf_raspberry_pi";
    "i686-linux" = "linux_x86";
    "x86_64-linux" = "linux_x86_64";
  };
  bindir =
    platforms."${stdenv.hostPlatform.system}"
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  icon = fetchurl {
    hash = "sha256-ld2GCOhBhMThuUYBNa+2iTdY2HsYBRyApWiHTPuVgKA=";
    url = "https://warmplace.ru/soft/sunvox/images/icon.png";
  };

in
stdenv.mkDerivation (finalAttrs: {
  pname = "sunvox";
  version = "2.1.4d";

  src = fetchzip {
    hash = "sha256-HQwA9FyK1xdcTsWWfX7ZJ0KcnuwRz25ztjlrNIDhFQY=";

    urls = [
      "https://www.warmplace.ru/soft/sunvox/sunvox-${finalAttrs.version}.zip"
      # Upstream removes downloads of older versions, please save bumped versions to archive.org
      "https://web.archive.org/web/20260501043715/https://www.warmplace.ru/soft/sunvox/sunvox-${finalAttrs.version}.zip"
    ];
  };

  nativeBuildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [
      autoPatchelfHook
      copyDesktopItems
      imagemagick
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      makeWrapper
    ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    libglvnd
    libx11
    libxi
    SDL2
  ];

  installPhase = ''
    runHook preInstall

    # Delete platform-specific data for all the platforms we're not building for
    find sunvox -mindepth 1 -maxdepth 1 -type d -not -name "${bindir}" -exec rm -r {} \;

    mkdir -p $out/{bin,share/sunvox}
    mv * $out/share/sunvox/

  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    for binary in $(find $out/share/sunvox/sunvox/${bindir}/ -type f -executable); do
      mv $binary $out/bin/$(basename $binary)
    done

    # Cleanup, make sure we didn't miss anything
    find $out/share/sunvox/sunvox -type f -name readme.txt -delete
    rmdir $out/share/sunvox/sunvox/${bindir} $out/share/sunvox/sunvox

    # Resize & install icons
    for size in 16 24 32 48 64 128 256; do
      mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps
      magick ${icon} -resize ''${size}x''${size} \
      $out/share/icons/hicolor/''${size}x''${size}/apps/sunvox.png
    done

  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir $out/Applications
    ln -s $out/share/sunvox/sunvox/${bindir}/SunVox.app $out/Applications/
    ln -s $out/share/sunvox/sunvox/${bindir}/reset_sunvox $out/bin/

    # Need to use a wrapper, binary checks for files relative to the path it was called via
    makeWrapper $out/Applications/SunVox.app/Contents/MacOS/SunVox $out/bin/sunvox
  ''
  + ''

    runHook postInstall
  '';

  desktopItems =
    let
      sunvoxDesktop =
        variant:
        makeDesktopItem {
          categories = [
            "AudioVideo"
            "Audio"
            "Midi"
          ];

          comment = "Modular synthesizer with pattern-based sequencer";
          desktopName = "SunVox" + lib.optionalString (variant != null) " (${variant})";
          exec = "sunvox" + lib.optionalString (variant != null) "_${lib.strings.toLower variant}";
          genericName = "Modular Synthesizer";
          icon = "sunvox";
          name = "sunvox" + lib.optionalString (variant != null) "-${lib.strings.toLower variant}";
        };
    in
    lib.optionals stdenv.hostPlatform.isLinux (
      [
        (sunvoxDesktop null)
      ]
      ++ lib.optionals (stdenv.hostPlatform.isx86_64 || stdenv.hostPlatform.isAarch64) [
        (sunvoxDesktop "OpenGL")
      ]
      ++ lib.optionals (stdenv.hostPlatform.isi686) [
        (sunvoxDesktop "LoFi")
      ]
    );

  dontBuild = true;
  dontConfigure = true;

  runtimeDependencies = lib.optionals stdenv.hostPlatform.isLinux [
    libjack2
  ];

  meta = {
    description = "Small, fast and powerful modular synthesizer with pattern-based sequencer";
    homepage = "https://www.warmplace.ru/soft/sunvox/";
    license = lib.licenses.unfreeRedistributable;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      puffnfresh
      OPNA2608
    ];

    platforms = lib.attrNames platforms;
  };
})
