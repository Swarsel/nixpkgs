{
  lib,
  stdenv,
  astring,
  fetchzip,
  findlib,
  ocaml,
  ocamlbuild,
  topkg,
}:

stdenv.mkDerivation rec {
  inherit (topkg) buildPhase installPhase;
  pname = "ocaml${ocaml.version}-ocb-stubblr";
  version = "0.1.1";

  src = fetchzip {
    url = "https://github.com/pqwy/ocb-stubblr/releases/download/v${version}/ocb-stubblr-${version}.tbz";
    hash = "sha256-Zd9a2EFT5j944xCFmWD4Td21VB7uGHZoNE4yvgfI9y0=";
    name = "src.tar.bz";
  };

  patches = [ ./pkg-config.patch ];
  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    ocamlbuild
    topkg
  ];

  buildInputs = [
    topkg
    ocamlbuild
  ];

  propagatedBuildInputs = [ astring ];

  meta = {
    inherit (ocaml.meta) platforms;
    description = "OCamlbuild plugin for C stubs";
    homepage = "https://github.com/pqwy/ocb-stubblr";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };
}
