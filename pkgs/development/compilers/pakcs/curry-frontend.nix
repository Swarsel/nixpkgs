{
  lib,
  Cabal,
  base,
  binary,
  bytestring,
  containers,
  directory,
  extra,
  file-embed,
  filepath,
  mkDerivation,
  mtl,
  network-uri,
  parsec,
  pretty,
  process,
  set-extra,
  template-haskell,
  time,
  transformers,
}:
mkDerivation {
  pname = "curry-frontend";
  version = "2.1.0";
  src = ./.;
  description = "Compile the functional logic language Curry to several intermediate formats";
  enableSeparateDataOutput = true;
  executableHaskellDepends = [ base ];
  homepage = "http://curry-language.org";
  isExecutable = true;
  isLibrary = true;

  libraryHaskellDepends = [
    base
    binary
    bytestring
    containers
    directory
    extra
    file-embed
    filepath
    mtl
    network-uri
    parsec
    pretty
    process
    set-extra
    template-haskell
    time
    transformers
  ];

  license = lib.licenses.bsd3;
  mainProgram = "curry-frontend";

  testHaskellDepends = [
    base
    bytestring
    Cabal
    containers
    directory
    extra
    file-embed
    filepath
    mtl
    network-uri
    pretty
    process
    set-extra
    template-haskell
    transformers
  ];
}
