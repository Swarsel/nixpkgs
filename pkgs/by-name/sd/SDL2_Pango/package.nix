{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  autoreconfHook,
  freetype,
  pango,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sdl2-pango";
  version = "2.1.5";

  src = fetchFromGitHub {
    owner = "markuskimius";
    repo = "SDL2_Pango";
    rev = "v${finalAttrs.version}";
    hash = "sha256-8SL5ylxi87TuKreC8m2kxlLr8rcmwYYvwkp4vQZ9dkc=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    SDL2
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    SDL2
    freetype
    pango
  ];

  meta = {
    inherit (SDL2.meta) platforms;
    description = "Library for graphically rendering internationalized and tagged text in SDL2 using TrueType fonts";
    homepage = "https://github.com/markuskimius/SDL2_Pango";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    teams = [ lib.teams.sdl ];
  };
})
