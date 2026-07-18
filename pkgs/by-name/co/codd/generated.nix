{
  lib,
  QuickCheck,
  aeson,
  aeson-pretty,
  ansi-terminal,
  attoparsec,
  base,
  bytestring,
  clock,
  containers,
  criterion-measurement,
  deepseq,
  dlist,
  filepath,
  formatting,
  hashable,
  haxl,
  hspec,
  hspec-core,
  hspec-expectations,
  mkDerivation,
  mtl,
  network-uri,
  optparse-applicative,
  postgresql-libpq,
  postgresql-simple,
  random,
  resourcet,
  statistics,
  streaming,
  text,
  time,
  transformers,
  typed-process,
  unliftio,
  unliftio-core,
  unordered-containers,
  uuid,
  vector,
}:
mkDerivation {
  pname = "codd";
  version = "0.1.8";
  src = ./.;

  benchmarkHaskellDepends = [
    aeson
    base
    criterion-measurement
    deepseq
    hspec
    hspec-core
    hspec-expectations
    statistics
    streaming
    text
    vector
  ];

  executableHaskellDepends = [
    base
    optparse-applicative
    postgresql-simple
    text
    time
  ];

  homepage = "https://github.com/mzabani/codd#readme";
  isExecutable = true;
  isLibrary = true;

  libraryHaskellDepends = [
    aeson
    aeson-pretty
    ansi-terminal
    attoparsec
    base
    bytestring
    clock
    containers
    deepseq
    dlist
    filepath
    formatting
    hashable
    haxl
    mtl
    network-uri
    postgresql-libpq
    postgresql-simple
    resourcet
    streaming
    text
    time
    transformers
    unliftio
    unliftio-core
    unordered-containers
    uuid
    vector
  ];

  license = lib.licenses.bsd3;
  mainProgram = "codd";

  testHaskellDepends = [
    aeson
    attoparsec
    base
    containers
    filepath
    hashable
    hspec
    hspec-core
    mtl
    network-uri
    postgresql-simple
    QuickCheck
    random
    resourcet
    streaming
    text
    time
    typed-process
    unliftio
    uuid
  ];
}
