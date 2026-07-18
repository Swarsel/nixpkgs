{
  lib,
  fetchFromGitHub,
  cabal-install,
  ghc,
  mkDerivation,
}:

mkDerivation {
  pname = "cubical-mini";
  version = "0.5-unstable-2025-06-13";

  src = fetchFromGitHub {
    owner = "cmcmA20";
    repo = "cubical-mini";
    rev = "1776874d13d0b811e6eeb70d0e5a52b4d2a978d2";
    hash = "sha256-UxWOS+uzP9aAaMdSueA2CAuzWkImGAoKxroarcgpk+w=";
  };

  nativeBuildInputs = [
    ghc
    cabal-install
  ];

  # Makefile uses `cabal run` which tries to write its default config to $HOME and download package
  # lists. We need to create an empty config file to make cabal work offline.
  buildPhase = ''
    runHook preBuild
    export HOME=$TMP
    mkdir $HOME/.cabal
    touch $HOME/.cabal/config
    make
    runHook postBuild
  '';

  meta = {
    description = "Nonstandard library for Cubical Agda";
    homepage = "https://github.com/cmcmA20/cubical-mini";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ thelissimus ];
    platforms = lib.platforms.unix;
  };
}
