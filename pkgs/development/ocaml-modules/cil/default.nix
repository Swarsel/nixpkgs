{
  lib,
  stdenv,
  fetchurl,
  findlib,
  ocaml,
  ocamlbuild,
  perl,
}:

stdenv.mkDerivation rec {
  pname = "ocaml-cil";
  version = "1.7.3";

  src = fetchurl {
    url = "mirror://sourceforge/cil/cil-${version}.tar.gz";
    sha256 = "05739da0b0msx6kmdavr3y2bwi92jbh3szc35d7d8pdisa8g5dv9";
  };

  strictDeps = true;

  nativeBuildInputs = [
    perl
    ocaml
    findlib
    ocamlbuild
  ];

  preConfigure = ''
    substituteInPlace Makefile.in --replace 'MACHDEPCC=gcc' 'MACHDEPCC=$(CC)'
    export FORCE_PERL_PREFIX=1
  '';

  createFindlibDestdir = true;
  prefixKey = "-prefix=";

  meta = {
    description = "Front-end for the C programming language that facilitates program analysis and transformation";
    homepage = "https://sourceforge.net/projects/cil/";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.vbgl ];
    platforms = ocaml.meta.platforms or [ ];
    broken = lib.versionAtLeast ocaml.version "4.06";
  };
}
