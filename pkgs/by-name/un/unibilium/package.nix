{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libtool,
  ncurses,
  perl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "unibilium";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "neovim";
    repo = "unibilium";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-6bFZtR8TUZJembRBj6wUUCyurUdsn3vDGnCzCti/ESc=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    perl
    libtool
  ];

  buildInputs = [ ncurses ];
  enableParallelBuilding = true;

  meta = {
    description = "Very basic terminfo library";
    homepage = "https://github.com/neovim/unibilium";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
