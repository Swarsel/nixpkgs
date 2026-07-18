# This file has been autogenerate with cabal2nix.
# Update via ./update.sh
{
  lib,
  base,
  bytestring,
  cmdargs,
  containers,
  directory,
  fetchzip,
  file-embed,
  filepath,
  megaparsec,
  mkDerivation,
  mtl,
  parser-combinators,
  pretty-simple,
  process,
  safe-exceptions,
  scientific,
  text,
  transformers,
  unix,
}:
mkDerivation {
  pname = "nixfmt";
  version = "1.4.0";

  src = fetchzip {
    url = "https://github.com/nixos/nixfmt/archive/v1.4.0.tar.gz";
    sha256 = "123mc70ly0glvm8nm4a52fz4xa1619gf1g5k2m45cazb1d6di6z7";
  };

  description = "Official formatter for Nix code";

  executableHaskellDepends = [
    base
    bytestring
    cmdargs
    directory
    file-embed
    filepath
    process
    safe-exceptions
    text
    transformers
    unix
  ];

  homepage = "https://github.com/NixOS/nixfmt";
  isExecutable = true;
  isLibrary = true;
  jailbreak = true;

  libraryHaskellDepends = [
    base
    containers
    megaparsec
    mtl
    parser-combinators
    pretty-simple
    scientific
    text
    transformers
  ];

  license = lib.meta.getLicenseFromSpdxId "MPL-2.0";
  mainProgram = "nixfmt";
}
