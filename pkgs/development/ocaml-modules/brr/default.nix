{
  lib,
  stdenv,
  fetchurl,
  findlib,
  js_of_ocaml-compiler,
  js_of_ocaml-toplevel,
  ocaml,
  ocamlbuild,
  topkg,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (topkg) buildPhase installPhase;
  pname = "ocaml${ocaml.version}-brr";
  version = "0.0.8";

  src = fetchurl {
    url = "https://erratique.ch/software/brr/releases/brr-${finalAttrs.version}.tbz";
    hash = "sha256-g4ROHy9rHlaEFi5+euyRuEKK5HwKJWPmFkdvFhdIYgg=";
  };

  buildInputs = [
    ocaml
    findlib
    ocamlbuild
    topkg
  ];

  propagatedBuildInputs = [
    js_of_ocaml-compiler
    js_of_ocaml-toplevel
  ];

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Toolkit for programming browsers in OCaml";
    homepage = "https://erratique.ch/software/brr";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
