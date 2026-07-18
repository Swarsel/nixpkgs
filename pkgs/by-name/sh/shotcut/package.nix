{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  cmake,
  ffmpeg,
  fftw,
  frei0r,
  gettext,
  gitUpdater,
  jack1,
  ladspaPlugins,
  pkg-config,
  qt6,
  qt6Packages,
  replaceVars,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "shotcut";
  version = "26.6.25";

  src = fetchFromGitHub {
    owner = "mltframework";
    repo = "shotcut";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iFaN3WB0CYdENXM4XLoi2RxCOG7kHmvfLRItvxCKYLA=";
  };

  patches = [
    (replaceVars ./fix-mlt-ffmpeg-path.patch {
      inherit ffmpeg;
      mlt = qt6Packages.mlt;
    })
  ];

  nativeBuildInputs = [
    pkg-config
    cmake
    qt6.wrapQtAppsHook
    wrapGAppsHook3
  ];

  buildInputs = [
    SDL2
    frei0r
    ladspaPlugins
    gettext
    qt6Packages.mlt
    fftw
    qt6.qtbase
    qt6.qttools
    qt6.qtmultimedia
    qt6.qtcharts
    qt6.qtwayland
    qt6.qtwebsockets
  ];

  cmakeFlags = [ "-DSHOTCUT_VERSION=${finalAttrs.version}" ];
  env.NIX_CFLAGS_COMPILE = "-DSHOTCUT_NOUPGRADE";

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir $out/Applications $out/bin
    mv $out/Shotcut.app $out/Applications/Shotcut.app
    ln -s $out/Applications/Shotcut.app/Contents/MacOS/Shotcut $out/bin/shotcut
  '';

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dontWrapGApps = true;

  qtWrapperArgs = [
    "--set FREI0R_PATH ${frei0r}/lib/frei0r-1"
    "--set LADSPA_PATH ${ladspaPlugins}/lib/ladspa"
    "--prefix LD_LIBRARY_PATH : ${
      lib.makeLibraryPath ([ SDL2 ] ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [ jack1 ])
    }"
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Free, open source, cross-platform video editor";

    longDescription = ''
      An official binary for Shotcut, which includes all the
      dependencies pinned to specific versions, is provided on
      http://shotcut.org.

      If you encounter problems with this version, please contact the
      nixpkgs maintainer(s). If you wish to report any bugs upstream,
      please use the official build from shotcut.org instead.
    '';

    homepage = "https://shotcut.org";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      woffs
      peti
      nick-linux
    ];

    platforms = lib.platforms.unix;
    mainProgram = "shotcut";
  };
})
