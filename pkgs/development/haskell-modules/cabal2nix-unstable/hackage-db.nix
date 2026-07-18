# This file defines hackage-db-unstable, used by maintainers/scripts/haskell/regenerate-hackage-packages.sh.
{
  lib,
  Cabal,
  aeson,
  base,
  bytestring,
  containers,
  directory,
  exceptions,
  fetchzip,
  filepath,
  mkDerivation,
  tar,
  time,
}:
mkDerivation {
  pname = "hackage-db";
  version = "2.1.3-unstable-2026-03-30";

  src = fetchzip {
    url = "https://github.com/NixOS/cabal2nix/archive/41239bcc0622a0975c6705a03a44dfeffeb56f23.tar.gz";
    sha256 = "01qj6cvaif0810v83r6izcj1bbfpcqqxw4wybq04qsq92sqybpw2";
  };

  description = "Access cabal-install's Hackage database via Data.Map";
  homepage = "https://github.com/NixOS/cabal2nix/tree/master/hackage-db#readme";
  isExecutable = true;
  isLibrary = true;

  libraryHaskellDepends = [
    aeson
    base
    bytestring
    Cabal
    containers
    directory
    exceptions
    filepath
    tar
    time
  ];

  license = lib.licensesSpdx."BSD-3-Clause";
  postUnpack = "sourceRoot+=/hackage-db; echo source root reset to $sourceRoot";
}
