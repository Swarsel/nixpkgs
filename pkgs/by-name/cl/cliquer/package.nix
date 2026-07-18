{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cliquer";
  version = "1.23";

  # autotoolized version of the original cliquer
  src = fetchFromGitHub {
    owner = "dimpase";
    repo = "autocliquer";
    rev = "v${finalAttrs.version}";
    hash = "sha256-SGpur3sF1dYQU97wprERUqlr6LIX+NyXZVl0eSEd3uM=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  doCheck = true;

  meta = {
    description = "Routines for clique searching";

    longDescription = ''
      Cliquer is a set of C routines for finding cliques in an arbitrary weighted graph.
      It uses an exact branch-and-bound algorithm developed by Patric Östergård.
      It is designed with the aim of being efficient while still being flexible and
      easy to use.
    '';

    homepage = "https://users.aalto.fi/~pat/cliquer.html";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "cl";
    downloadPage = finalAttrs.src.meta.homepage; # autocliquer
    teams = [ lib.teams.sage ];
  };
})
