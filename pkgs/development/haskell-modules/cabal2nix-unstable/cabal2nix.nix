# This file defines cabal2nix-unstable, used by maintainers/scripts/haskell/regenerate-hackage-packages.sh.
{
  lib,
  Cabal,
  aeson,
  ansi-terminal,
  base,
  bytestring,
  containers,
  deepseq,
  directory,
  distribution-nixpkgs,
  fetchzip,
  filepath,
  hackage-db,
  hopenssl,
  hpack,
  language-nix,
  lens,
  mkDerivation,
  monad-par,
  monad-par-extras,
  mtl,
  optparse-applicative,
  pretty,
  prettyprinter,
  process,
  split,
  tasty,
  tasty-golden,
  text,
  time,
  transformers,
  yaml,
}:
mkDerivation {
  pname = "cabal2nix";
  version = "2.21.3-unstable-2026-03-30";

  src = fetchzip {
    url = "https://github.com/NixOS/cabal2nix/archive/41239bcc0622a0975c6705a03a44dfeffeb56f23.tar.gz";
    sha256 = "01qj6cvaif0810v83r6izcj1bbfpcqqxw4wybq04qsq92sqybpw2";
  };

  preCheck = ''
    export PATH="$PWD/dist/build/cabal2nix:$PATH"
    export HOME="$TMPDIR/home"
  '';

  description = "Convert Cabal files into Nix build instructions";

  executableHaskellDepends = [
    aeson
    base
    bytestring
    Cabal
    containers
    directory
    distribution-nixpkgs
    filepath
    hopenssl
    language-nix
    lens
    monad-par
    monad-par-extras
    mtl
    optparse-applicative
    pretty
  ];

  homepage = "https://github.com/nixos/cabal2nix#readme";
  isExecutable = true;
  isLibrary = true;

  libraryHaskellDepends = [
    aeson
    ansi-terminal
    base
    bytestring
    Cabal
    containers
    deepseq
    directory
    distribution-nixpkgs
    filepath
    hackage-db
    hopenssl
    hpack
    language-nix
    lens
    optparse-applicative
    pretty
    prettyprinter
    process
    split
    text
    time
    transformers
    yaml
  ];

  license = lib.licensesSpdx."BSD-3-Clause";
  postUnpack = "sourceRoot+=/cabal2nix; echo source root reset to $sourceRoot";

  testHaskellDepends = [
    base
    Cabal
    containers
    directory
    filepath
    language-nix
    lens
    pretty
    process
    tasty
    tasty-golden
  ];
}
