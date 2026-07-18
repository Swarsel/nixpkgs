{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:

stdenv.mkDerivation {
  pname = "ent";
  version = "1.1";

  src = fetchurl {
    url = "https://www.fourmilab.ch/random/random.zip";
    sha256 = "1v39jlj3lzr5f99avzs2j2z6anqqd64bzm1pdf6q84a5n8nxckn1";
  };

  nativeBuildInputs = [ unzip ];
  buildFlags = lib.optional stdenv.cc.isClang "CC=clang";

  installPhase = ''
    mkdir -p $out/bin
    cp ent $out/bin/
  '';

  # Work around the "unpacker appears to have produced no directories"
  # case that happens when the archive doesn't have a subdirectory.
  sourceRoot = ".";

  meta = {
    description = "Pseudorandom Number Sequence Test Program";
    homepage = "https://www.fourmilab.ch/random/";
    license = lib.licenses.publicDomain;
    platforms = lib.platforms.all;
    mainProgram = "ent";
  };
}
