{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  cmake,
  docbook_xsl,
  git,
  ncurses,
  nix-update-script,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "sdl-jstest";
  version = "0.2.2-unstable-2026-07-03";

  src = fetchFromGitHub {
    owner = "Grumbel";
    repo = "sdl-jstest";
    rev = "b8eae565aefa8f1723eb0a64be94de309525d204";
    hash = "sha256-kS1FcoRUInVkksI2SKQ5oCnEYSZzpf3X+db1KmRzJwI=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    docbook_xsl
    git
  ];

  buildInputs = [
    SDL2
    ncurses
  ];

  cmakeFlags = [ (lib.cmakeBool "BUILD_SDL_JSTEST" false) ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Simple SDL joystick test application for the console";
    homepage = "https://github.com/Grumbel/sdl-jstest";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      yuannan
    ];

    platforms = lib.platforms.linux;
    mainProgram = "sdl2-jstest";
  };
}
