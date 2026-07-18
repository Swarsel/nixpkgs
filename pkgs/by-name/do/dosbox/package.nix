{
  lib,
  stdenv,
  fetchurl,
  SDL,
  SDL_net,
  SDL_sound,
  autoreconfHook,
  binutils,
  copyDesktopItems,
  fetchpatch,
  graphicsmagick,
  libGL,
  libGLU,
  libpng,
  makeDesktopItem,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dosbox";
  version = "0.74-3";

  src = fetchurl {
    url = "mirror://sourceforge/dosbox/dosbox-${finalAttrs.version}.tar.gz";
    hash = "sha256-wNE91+0u02O2jeYVR1eB6JHNWC6BYrXDZpE3UCIiJgo=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-HSO29/LgZRKQ3HQBA0QF5henG8pCSoe1R2joYNPcUcE=";
      includes = [ "src/gui/render_templates_sai.h" ];
      url = "https://github.com/joncampbell123/dosbox-x/commit/006d5727d36d1ec598e387f2f1a3c521e3673dcb.patch";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    copyDesktopItems
    graphicsmagick
    SDL
  ];

  buildInputs = [
    SDL
    SDL_net
    SDL_sound
    libpng
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    libGL
    libGLU
  ];

  configureFlags = lib.optional stdenv.hostPlatform.isDarwin "--disable-sdltest";
  # Tests for SDL_net.h for modem & IPX support, not automatically picked up due to being in SDL subdirectory
  env.NIX_CFLAGS_COMPILE = "-I${lib.getDev SDL_net}/include/SDL";

  postInstall = ''
    mkdir -p $out/share/icons/hicolor/256x256/apps
    gm convert src/dosbox.ico $out/share/icons/hicolor/256x256/apps/dosbox.png
  '';

  depsBuildBuild = lib.optionals (!stdenv.buildPlatform.isDarwin) [
    binutils # build calls `ar`
  ];

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Emulator"
        "Game"
      ];

      comment = "x86 dos emulator";
      desktopName = "DOSBox";
      exec = "dosbox";
      genericName = "DOS emulator";
      icon = "dosbox";
      name = "dosbox";
    })
  ];

  enableParallelBuilding = true;
  hardeningDisable = [ "format" ];

  meta = {
    description = "DOS emulator";

    longDescription = ''
      DOSBox is an emulator that recreates a MS-DOS compatible environment
      (complete with Sound, Input, Graphics and even basic networking). This
      environment is complete enough to run many classic MS-DOS games completely
      unmodified. In order to utilize all of DOSBox's features you need to first
      understand some basic concepts about the MS-DOS environment.
    '';

    homepage = "http://www.dosbox.com/";
    changelog = "https://www.dosbox.com/wiki/Releases";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "dosbox";
  };
})
