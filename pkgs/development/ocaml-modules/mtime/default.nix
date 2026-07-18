{
  lib,
  stdenv,
  fetchurl,
  findlib,
  ocaml,
  ocamlbuild,
  topkg,
}:

stdenv.mkDerivation rec {
  inherit (topkg) buildPhase installPhase;
  pname = "ocaml${ocaml.version}-mtime";
  version = "2.1.0";

  src = fetchurl {
    url = "https://erratique.ch/software/mtime/releases/mtime-${version}.tbz";
    sha256 = "sha256-CXyygC43AerZVy4bSD1aKMbi8KOUSfqvm0StiomDTYg=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    ocamlbuild
    topkg
  ];

  buildInputs = [ topkg ];

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Monotonic wall-clock time for OCaml";
    homepage = "https://erratique.ch/software/mtime";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.vbgl ];
    broken = !(lib.versionAtLeast ocaml.version "4.08");
  };
}
