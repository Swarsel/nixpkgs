{
  lib,
  stdenv,
  SDL,
  alsa-lib,
  boost,
  copyDesktopItems,
  dos2unix,
  fetchFromBitbucket,
  fetchpatch2,
  flac,
  lame,
  libpulseaudio,
  libvorbis,
  makeDesktopItem,
  nix-update-script,
  openal,
  qt5,
  zip,
  zlib,
  withAlsa ? stdenv.hostPlatform.isLinux,
  withFlac ? true,
  # File backends (for decoding and encoding)
  withMp3 ? true,
  withOgg ? true,
  # Audio backends (for playback)
  withOpenal ? false,
  withOss ? false,
  withPulse ? stdenv.hostPlatform.isLinux,
  # GUI audio player
  withQt ? true,
  withSDL ? false,
}:
let
  dlopenBuildInputs =
    [ ]
    ++ lib.optional withMp3 lame
    ++ lib.optional withOgg libvorbis
    ++ lib.optional withFlac flac
    ++ lib.optional withOpenal openal
    ++ lib.optional withSDL SDL
    ++ lib.optional withAlsa alsa-lib
    ++ lib.optional withPulse libpulseaudio;
  supportWayland = (!stdenv.hostPlatform.isDarwin);
  platformName = "linux";
  staticBuildInputs = [
    boost
    zlib
  ]
  ++ lib.optional withQt (if supportWayland then qt5.qtwayland else qt5.qtbase);
in
stdenv.mkDerivation rec {
  pname = "zxtune";
  version = "5101";

  src = fetchFromBitbucket {
    owner = "zxtune";
    repo = "zxtune";
    rev = "r${version}";
    hash = "sha256-C+1tmQ8cKGpigWDh5p0mqv9B7/Tv8iJ4JVc835Q4y40=";
  };

  outputs = [ "out" ];

  patches = [
    # fix https://hydra.nixos.org/build/317966891
    (fetchpatch2 {
      hash = "sha256-F6gD+w4lFymSRHXgDngYX/dZI26f7onOmYFlHkPKms8=";
      name = "xmp-fix-for-gcc-15.patch";
      url = "https://github.com/vitamin-caig/zxtune/commit/7f853a38924f78a25b86ac674b41e2f0fd2524a5.patch?full_index=1";
    })
    (fetchpatch2 {
      hash = "sha256-uEa2LY/r/jVWHHEpFtsQba66YdIjA82fDlm+StKp/EI=";
      name = "update-vgm.patch";
      url = "https://github.com/vitamin-caig/zxtune/commit/31e3ff7a8d13b72e6f72caecd15ae87cefca0465.patch?full_index=1";
    })
    ./disable_updates.patch
  ];

  # Fix use of old OpenAL header path
  postPatch = ''
    substituteInPlace src/sound/backends/gates/openal_api.h \
      --replace "#include <OpenAL/" "#include <AL/"
  '';

  strictDeps = true;

  nativeBuildInputs = lib.optionals withQt [
    zip
    qt5.wrapQtAppsHook
    copyDesktopItems
  ];

  buildInputs = staticBuildInputs ++ dlopenBuildInputs;

  buildPhase =
    let
      setOptionalSupport = name: var: "support_${name}=" + (if var then "1" else "");
      makeOptsCommon = [
        "-j$NIX_BUILD_CORES"
        "root.version=${src.rev}"
        "system.zlib=1"
        "platform=${platformName}"
        ''includes.dirs.${platformName}="${lib.makeSearchPathOutput "dev" "include" buildInputs}"''
        ''libraries.dirs.${platformName}="${lib.makeLibraryPath staticBuildInputs}"''
        ''ld_flags="-Wl,-rpath=\"${lib.makeLibraryPath dlopenBuildInputs}\""''
        (setOptionalSupport "mp3" withMp3)
        (setOptionalSupport "ogg" withOgg)
        (setOptionalSupport "flac" withFlac)
        (setOptionalSupport "openal" withOpenal)
        (setOptionalSupport "sdl" withSDL)
        (setOptionalSupport "oss" withOss)
        (setOptionalSupport "alsa" withAlsa)
        (setOptionalSupport "pulseaudio" withPulse)
      ];
      makeOptsQt = [
        "tools.uic=${qt5.qtbase.dev}/bin/uic"
        "tools.moc=${qt5.qtbase.dev}/bin/moc"
        "tools.rcc=${qt5.qtbase.dev}/bin/rcc"
      ];
    in
    ''
      runHook preBuild
      make ${toString makeOptsCommon} -C apps/xtractor
      make ${toString makeOptsCommon} -C apps/zxtune123
    ''
    + lib.optionalString withQt ''
      make ${toString (makeOptsCommon ++ makeOptsQt)} -C apps/zxtune-qt
    ''
    + ''
      runHook postBuild
    '';

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/linux/release/xtractor -t $out/bin
    install -Dm755 bin/linux/release/zxtune123 -t $out/bin
  ''
  + lib.optionalString withQt ''
    install -Dm755 bin/linux/release/zxtune-qt -t $out/bin
    install -Dm755 apps/zxtune-qt/res/theme_default/zxtune.png -t $out/share/icons/hicolor/48x48/apps
  ''
  + ''
    runHook postInstall
  '';

  preFixup = lib.optionalString withQt ''
    wrapQtApp "$out/bin/zxtune-qt"
  '';

  desktopItems = lib.optionals withQt [
    (makeDesktopItem {
      categories = [ "Audio" ];
      comment = meta.description;
      desktopName = "ZXTune";
      exec = "zxtune-qt";
      genericName = "ZXTune";
      icon = "zxtune";
      name = "ZXTune";
      type = "Application";
    })
  ];

  # Libs from dlopenBuildInputs are found with dlopen. Do not shrink rpath. Can
  # check output of 'out/bin/zxtune123 --list-backends' to verify all plugins
  # load ("Status: Available" or "Status: Failed to load dynamic library...").
  dontPatchELF = true;
  # Only wrap the gui
  dontWrapQtApps = true;

  prePatch = ''
    # update-vgm.patch : Hunk #1 FAILED at 18 (different line endings)
    find 3rdparty/vgm/ -type f -exec ${dos2unix}/bin/dos2unix {} \;
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "r([0-9]+)"
    ];
  };

  meta = {
    description = "Crossplatform chiptunes player";

    longDescription = ''
      Chiptune music player with truly extensive format support. Supported
      formats/chips include AY/YM, ZX Spectrum, PC, Amiga, Atari, Acorn, Philips
      SAA1099, MOS6581 (Commodore 64), NES, SNES, GameBoy, Atari, TurboGrafX,
      Nintendo DS, Sega Master System, and more. Powered by vgmstream, OpenMPT,
      sidplay, and many other libraries.
    '';

    homepage = "https://zxtune.bitbucket.io/";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      pbsds
      EBADBEEF
    ];

    # zxtune supports mac and windows, but more work will be needed to
    # integrate with the custom make system (see platformName above)
    platforms = lib.platforms.linux;
    mainProgram = if withQt then "zxtune-qt" else "zxtune123";
  };
}
