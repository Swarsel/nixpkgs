{
  lib,
  stdenv,
  fetchurl,
  cmdliner,
  findlib,
  ocaml,
  ocamlbuild,
  topkg,
}:

stdenv.mkDerivation rec {
  inherit (topkg) buildPhase installPhase;
  pname = "ocaml${ocaml.version}-fmt";
  version = "0.11.0";

  src = fetchurl {
    url = "https://erratique.ch/software/fmt/releases/fmt-${version}.tbz";
    sha256 = "sha256-hXz9R6VLUkKc2bPiZl5EFzzRvTtDW+znFy+YStU3ahs=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    ocamlbuild
    topkg
  ];

  buildInputs = [
    cmdliner
    topkg
  ];

  meta = {
    inherit (ocaml.meta) platforms;
    description = "OCaml Format pretty-printer combinators";
    homepage = "https://erratique.ch/software/fmt";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
    broken = lib.versionOlder ocaml.version "4.08";
  };
}
