{
  lib,
  stdenv,
  fetchurl,
  findlib,
  ocaml,
  ocamlbuild,
  topkg,
}:

let
  homepage = "https://erratique.ch/software/gg";
  version = "1.0.0";
in

stdenv.mkDerivation {

  inherit version;
  inherit (topkg) buildPhase installPhase;
  pname = "ocaml${ocaml.version}-gg";

  src = fetchurl {
    url = "${homepage}/releases/gg-${version}.tbz";
    sha256 = "sha256:0j7bpj8k17csnz6v6frkz9aycywsb7xmznnb31g8rbfk3626f3ci";
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
    inherit homepage;
    inherit (ocaml.meta) platforms;
    description = "Basic types for computer graphics in OCaml";

    longDescription = ''
      Gg is an OCaml module providing basic types for computer graphics. It
      defines types and functions for floats, vectors, points, sizes,
      matrices, quaternions, axis aligned boxes, colors, color spaces, and
      raster data.
    '';

    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.jirkamarsik ];
    broken = !(lib.versionAtLeast ocaml.version "4.08");
  };
}
