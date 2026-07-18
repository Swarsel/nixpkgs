{
  lib,
  stdenv,
  fetchurl,
  brr,
  findlib,
  gg,
  ocaml,
  ocamlbuild,
  otfm,
  result,
  topkg,
  uchar,
  htmlcBackend ? true, # depends on brr
  pdfBackend ? true, # depends on otfm
}:

let
  inherit (lib) optionals versionOlder;
in
stdenv.mkDerivation (finalAttrs: {
  inherit (topkg) installPhase;
  pname = "vg";
  version = "0.9.5";

  src = fetchurl {
    url = "https://erratique.ch/software/vg/releases/vg-${finalAttrs.version}.tbz";
    hash = "sha256-qcTtvIfSUwzpUZDspL+54UTNvWY6u3BTvfGWF6c0Jvw=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    ocamlbuild
  ];

  buildInputs = [ topkg ];

  propagatedBuildInputs = [
    uchar
    result
    gg
  ]
  ++ optionals pdfBackend [
    otfm
  ]
  ++ optionals htmlcBackend [
    brr
  ];

  buildPhase =
    topkg.buildPhase
    + " --with-otfm ${lib.boolToString pdfBackend}"
    + " --with-brr ${lib.boolToString htmlcBackend}"
    + " --with-cairo2 false";

  name = "ocaml${ocaml.version}-${finalAttrs.pname}-${finalAttrs.version}";

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Declarative 2D vector graphics for OCaml";

    longDescription = ''
      Vg is an OCaml module for declarative 2D vector graphics. In Vg, images
      are values that denote functions mapping points of the cartesian plane
      to colors. The module provides combinators to define and compose these
      values.

      Renderers for PDF, SVG and the HTML canvas are distributed with the
      module. An API allows to implement new renderers.
    '';

    homepage = "https://erratique.ch/software/vg";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.jirkamarsik ];
    mainProgram = "vecho";
    broken = versionOlder ocaml.version "4.14";
  };
})
