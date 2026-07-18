{
  lib,
  attoparsec,
  base,
  fetchgit,
  filepath,
  hercules-ci-optparse-applicative,
  hpack,
  mkDerivation,
  nix-derivation,
  process,
  relude,
  unix,
}:
mkDerivation rec {
  pname = "nix-run";
  version = "0.1.0.0-alpha.2";

  src = fetchgit {
    url = "https://tangled.org/did:plc:mojgntlezho4qt7uvcfkdndg/nix-run";
    tag = version;
    hash = "sha256-vnYD3N32H6eEPLis8eNlglXVY+guP5DDKCf2z7CLzwA=";
  };

  executableHaskellDepends = [
    attoparsec
    base
    filepath
    hercules-ci-optparse-applicative
    nix-derivation
    process
    relude
    unix
  ];

  homepage = "https://tangled.org/weethet.eurosky.social/nix-run";
  isExecutable = true;
  isLibrary = false;
  libraryToolDepends = [ hpack ];
  license = lib.licenses.bsd3;
  mainProgram = "nix-run";
  prePatch = "hpack";
}
