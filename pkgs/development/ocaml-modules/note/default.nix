{
  lib,
  stdenv,
  fetchurl,
  brr,
  findlib,
  ocaml,
  ocamlbuild,
  topkg,
}:

stdenv.mkDerivation rec {
  inherit (topkg) buildPhase installPhase;
  pname = "ocaml${ocaml.version}-note";
  version = "0.0.3";

  src = fetchurl {
    url = "https://erratique.ch/software/note/releases/note-${version}.tbz";
    hash = "sha256-ZZOvCnyz7UWzFtGFI1uC0ZApzyylgZYM/HYIXGVXY2k=";
  };

  buildInputs = [
    ocaml
    findlib
    ocamlbuild
    topkg
  ];

  propagatedBuildInputs = [ brr ];

  meta = {
    inherit (ocaml.meta) platforms;
    description = "OCaml module for functional reactive programming";
    homepage = "https://erratique.ch/software/note";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
    broken = !(lib.versionAtLeast ocaml.version "4.08");
  };
}
