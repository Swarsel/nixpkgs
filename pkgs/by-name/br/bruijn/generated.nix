{
  lib,
  array,
  base,
  binary,
  bitstring,
  bytestring,
  clock,
  containers,
  deepseq,
  directory,
  fetchzip,
  filepath,
  haskeline,
  megaparsec,
  mkDerivation,
  mtl,
  optparse-applicative,
  process,
  random,
  time,
}:
mkDerivation {
  pname = "bruijn";
  version = "0-unstable-2026-07-05";

  src = fetchzip {
    url = "https://github.com/marvinborner/bruijn/archive/29a4a3e9620702f47d839a154d64489b8fdce1a7.tar.gz";
    sha256 = "18vxzgd6faq8djgpav4na1nvp0jid44vd52gn9a8smwr2xk44wnz";
  };

  enableSeparateDataOutput = true;

  executableHaskellDepends = [
    array
    base
    binary
    bitstring
    bytestring
    clock
    containers
    deepseq
    directory
    filepath
    haskeline
    megaparsec
    mtl
    optparse-applicative
    process
    random
    time
  ];

  homepage = "https://github.com/githubuser/bruijn#readme";
  isExecutable = true;
  isLibrary = true;

  libraryHaskellDepends = [
    array
    base
    binary
    bitstring
    bytestring
    clock
    containers
    deepseq
    directory
    filepath
    haskeline
    megaparsec
    mtl
    optparse-applicative
    process
    random
    time
  ];

  license = lib.licenses.mit;
  mainProgram = "bruijn";
  maintainers = [ lib.maintainers.defelo ];
}
