{
  lib,
  stdenv,
  fetchFromGitHub,
  camlzip,
  extlib,
  findlib,
  ocaml,
  which,
}:

stdenv.mkDerivation rec {
  pname = "ocaml${ocaml.version}-javalib";
  version = "3.2.2";

  src = fetchFromGitHub {
    owner = "javalib-team";
    repo = "javalib";
    rev = version;
    hash = "sha256-XaI7GTU/O5UEWuYX4yqaIRmEoH7FuvCg/+gtKbE/P1s=";
  };

  patches = [
    ./configure.sh.patch
    ./Makefile.config.example.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    which
    ocaml
    findlib
  ];

  propagatedBuildInputs = [
    camlzip
    extlib
  ];

  configurePlatforms = [ ];
  configureScript = "./configure.sh";
  createFindlibDestdir = true;
  dontAddPrefix = "true";
  dontAddStaticConfigureFlags = true;

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Library that parses Java .class files into OCaml data structures";
    homepage = "https://javalib-team.github.io/javalib/";
    license = lib.licenses.lgpl3;
    maintainers = [ lib.maintainers.vbgl ];
    broken = !(lib.versionAtLeast ocaml.version "4.08");
  };
}
