{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  swi-prolog,
  description ? "Parser for Attempto Controlled English (ACE)",
  lexiconPath ? "prolog/lexicon/clex_lexicon.pl",
  license ? lib.licenses.lgpl3,
  pname ? "ape",
}:

stdenv.mkDerivation {
  inherit pname;
  version = "2019-08-10";

  src = fetchFromGitHub {
    owner = "Attempto";
    repo = "APE";
    rev = "113b81621262d7a395779465cb09397183e6f74c";
    sha256 = "0xyvna2fbr18hi5yvm0zwh77q02dfna1g4g53z9mn2rmlfn2mhjh";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ swi-prolog ];

  buildPhase = ''
    make SHELL=${stdenv.shell} build
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ape.exe $out
    makeWrapper $out/ape.exe $out/bin/ape --add-flags ace
  '';

  patchPhase = ''
    # We move the file first to avoid "same file" error in the default case
    cp ${lexiconPath} new_lexicon.pl
    rm prolog/lexicon/clex_lexicon.pl
    cp new_lexicon.pl prolog/lexicon/clex_lexicon.pl
  '';

  meta = {
    description = description;
    homepage = "https://github.com/Attempto/APE";
    license = license;
    maintainers = with lib.maintainers; [ yrashk ];
    platforms = lib.platforms.unix;
    mainProgram = "ape";
  };
}
