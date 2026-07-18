{
  lib,
  Cabal-syntax,
  base,
  bytestring,
  cabal-install-parsers,
  containers,
  directory,
  fetchFromCodeberg,
  filepath,
  frontmatter,
  generic-lens-lite,
  mkDerivation,
  mtl,
  optparse-applicative,
  parsec,
  pretty,
  regex-applicative,
}:
mkDerivation rec {
  pname = "changelog-d";
  version = "1.0.2";

  src = fetchFromCodeberg {
    owner = "fgaz";
    repo = "changelog-d";
    rev = "v${version}";
    hash = "sha256-nPvuAkcFfK/NKXNBv8D2ePnB88WnjvmAIbzQHVvEXtk=";
  };

  description = "Concatenate changelog entries into a single one";
  doHaddock = false;

  executableHaskellDepends = [
    base
    bytestring
    Cabal-syntax
    directory
    filepath
    optparse-applicative
  ];

  isExecutable = true;
  isLibrary = false;

  libraryHaskellDepends = [
    base
    bytestring
    cabal-install-parsers
    Cabal-syntax
    containers
    directory
    filepath
    generic-lens-lite
    mtl
    parsec
    pretty
    regex-applicative
    frontmatter
  ];

  license = lib.licenses.gpl3Plus;
  mainProgram = "changelog-d";
}
