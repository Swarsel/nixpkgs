{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  gengetopt,
  pari,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lcalc";
  version = "2.2.1";

  src = fetchFromGitLab {
    owner = "sagemath";
    repo = "lcalc";
    tag = finalAttrs.version;
    hash = "sha256-L9502+lwSPLk63C14Pxa8OZWhnY4OqKv9WudZO2vP7E=";
  };

  nativeBuildInputs = [
    autoreconfHook
    gengetopt
    pkg-config
  ];

  buildInputs = [
    pari
  ];

  configureFlags = [
    "--with-pari"
  ];

  meta = {
    description = "Program for calculating with L-functions";
    homepage = "https://gitlab.com/sagemath/lcalc";
    license = with lib.licenses; [ gpl2 ];
    platforms = lib.platforms.all;
    mainProgram = "lcalc";
    teams = [ lib.teams.sage ];
  };
})
