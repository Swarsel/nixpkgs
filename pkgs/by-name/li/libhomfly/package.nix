{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  boehmgc,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libhomfly";
  version = "1.04";

  src = fetchFromGitHub {
    owner = "miguelmarco";
    repo = "libhomfly";
    rev = finalAttrs.version;
    hash = "sha256-ND2ZBKwHlRYTqxC+ltkCQ2lolNAkhZZm5hriIaOLqC4=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    boehmgc
  ];

  doCheck = true;

  meta = {
    description = "Library to compute the homfly polynomial of knots and links";
    homepage = "https://github.com/miguelmarco/libhomfly/";
    license = lib.licenses.unlicense;
    platforms = lib.platforms.all;
    teams = [ lib.teams.sage ];
  };
})
