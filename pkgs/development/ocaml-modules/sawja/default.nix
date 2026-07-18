{
  lib,
  stdenv,
  fetchFromGitHub,
  findlib,
  javalib,
  ocaml,
  which,
}:

let
  pname = "sawja";
  version = "1.5.12";
in
stdenv.mkDerivation {

  inherit version;
  pname = "ocaml${ocaml.version}-${pname}";

  src = fetchFromGitHub {
    owner = "javalib-team";
    repo = pname;
    rev = version;
    hash = "sha256-G1W8/G0TEcldnFnH/NAb9a6ZSGGP2fWTM47lI8bBHnw=";
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

  propagatedBuildInputs = [ javalib ];
  configurePlatforms = [ ];
  configureScript = "./configure.sh";
  createFindlibDestdir = true;
  dontAddPrefix = "true";
  dontAddStaticConfigureFlags = true;

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Library written in OCaml, relying on Javalib to provide a high level representation of Java bytecode programs";
    homepage = "http://sawja.inria.fr/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.vbgl ];
    broken = !(lib.versionAtLeast ocaml.version "4.08");
  };
}
