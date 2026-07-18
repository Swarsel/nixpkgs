{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  menhir,
}:

buildDunePackage (finalAttrs: {
  pname = "psmt2-frontend";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "ACoquereau";
    repo = "psmt2-frontend";
    rev = finalAttrs.version;
    hash = "sha256-cYY9x7QZjH7pdJyHMqfMXgHZ3/zJLp/6ntY6OSIo6Vs=";
  };

  nativeBuildInputs = [ menhir ];
  minimalOCamlVersion = "4.03";

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Simple parser and type-checker for polomorphic extension of the SMT-LIB 2 language";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.vbgl ];
  };

})
