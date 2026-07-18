{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libGL,
  libGLU,
  libx11,
  pkg-config,
  wrapGAppsHook4,
  wxwidgets_3_2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wxmacmolplt";
  version = "7.7.3";

  src = fetchFromGitHub {
    owner = "brettbode";
    repo = "wxmacmolplt";
    rev = "v${finalAttrs.version}";
    hash = "sha256-gFGstyq9bMmBaIS4QE6N3EIC9GxRvyJYUr8DUvwRQBc=";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
    wrapGAppsHook4
  ];

  buildInputs = [
    wxwidgets_3_2
    libGL
    libGLU
    libx11
    libx11.dev
  ];

  configureFlags = [ "LDFLAGS=-lGL" ];
  enableParallelBuilding = true;

  meta = {
    description = "Graphical user interface for GAMESS-US";
    homepage = "https://brettbode.github.io/wxmacmolplt/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      sheepforce
      markuskowa
    ];

    platforms = lib.platforms.linux;
    mainProgram = "wxmacmolplt";
  };
})
