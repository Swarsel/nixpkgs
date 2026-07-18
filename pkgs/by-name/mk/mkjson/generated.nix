{
  lib,
  fetchFromGitHub,
  Glob,
  aeson,
  base,
  bytestring,
  containers,
  criterion,
  doctest,
  mersenne-random-pure64,
  mkDerivation,
  mtl,
  optparse-applicative,
  parsec,
  random,
  regex-tdfa,
  scientific,
  text,
  time,
  unordered-containers,
  uuid,
  vector,
}:

mkDerivation rec {
  pname = "mkjson";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "mfussenegger";
    repo = "mkjson";
    rev = "${version}";
    hash = "sha256-+NDLFtsWWxHv/6XC9hJOAHPU6YED5oHqS/j5BPwNsqA=";
  };

  benchmarkHaskellDepends = [
    aeson
    base
    bytestring
    containers
    criterion
    mersenne-random-pure64
    mtl
    optparse-applicative
    parsec
    random
    regex-tdfa
    scientific
    text
    time
    unordered-containers
    uuid
    vector
  ];

  description = "Commandline tool to generate static or random JSON records";

  executableHaskellDepends = [
    aeson
    base
    bytestring
    containers
    mersenne-random-pure64
    mtl
    optparse-applicative
    parsec
    random
    regex-tdfa
    scientific
    text
    time
    unordered-containers
    uuid
    vector
  ];

  homepage = "https://github.com/mfussenegger/mkjson";
  isExecutable = true;
  isLibrary = false;

  libraryHaskellDepends = [
    aeson
    base
    bytestring
    containers
    mersenne-random-pure64
    mtl
    optparse-applicative
    parsec
    random
    regex-tdfa
    scientific
    text
    time
    unordered-containers
    uuid
    vector
  ];

  license = lib.licenses.mit;
  mainProgram = "mkjson";
  maintainers = with lib.maintainers; [ athas ];

  testHaskellDepends = [
    aeson
    base
    bytestring
    containers
    doctest
    Glob
    mersenne-random-pure64
    mtl
    optparse-applicative
    parsec
    random
    regex-tdfa
    scientific
    text
    time
    unordered-containers
    uuid
    vector
  ];
}
