{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  cmake,
  libx11,
  ncurses,
  nix-update-script,
  pkg-config,
  enableCurses ? true,
  enableGUI ? true,
  enableSDL ? true,
  enableTests ? true,
  enableX11 ? stdenv.hostPlatform.isLinux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hasciicam";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "dyne";
    repo = "hasciicam";
    tag = "v${finalAttrs.version}";
    hash = "sha256-agwNuIxO+o4HHkjd3TikYuVNgO0vlDPikcZoLDVLCUc=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs =
    lib.optionals enableSDL [ SDL2 ]
    ++ lib.optionals enableX11 [ libx11 ]
    ++ lib.optionals enableCurses [ ncurses ];

  cmakeFlags = [
    (lib.cmakeBool "HASCIICAM_ENABLE_TESTS" enableTests)
    (lib.cmakeBool "HASCIICAM_ENABLE_SDL" enableSDL)
    (lib.cmakeBool "HASCIICAM_ENABLE_GUI" enableGUI)
    (lib.cmakeBool "HASCIICAM_ENABLE_X11" enableX11)
    (lib.cmakeBool "HASCIICAM_ENABLE_CURSES" enableCurses)
  ];

  doCheck = enableTests;
  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "ASCII art webcam and video viewer";
    homepage = "https://github.com/dyne/hasciicam";
    changelog = "https://github.com/dyne/hasciicam/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ castorNova2 ];
    platforms = lib.platforms.unix;
    mainProgram = "hasciicam";
  };
})
