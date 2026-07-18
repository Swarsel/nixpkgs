{
  lib,
  stdenv,
  fetchurl,
  findlib,
  ocaml,
  ocamlbuild,
  topkg,
  uutf,
}:

let
  pname = "otfm";
  version = "0.4.0";
  webpage = "https://erratique.ch/software/${pname}";
in

stdenv.mkDerivation {

  inherit version;
  inherit (topkg) buildPhase installPhase;
  pname = "ocaml${ocaml.version}-${pname}";

  src = fetchurl {
    url = "${webpage}/releases/${pname}-${version}.tbz";
    hash = "sha256-02U23mYTy0ZJgSObDoyygPTGEMC4/Zge5bux4wshaEE=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    ocamlbuild
    topkg
  ];

  buildInputs = [ topkg ];
  propagatedBuildInputs = [ uutf ];

  meta = {
    inherit (ocaml.meta) platforms;
    description = "OpenType font decoder for OCaml";

    longDescription = ''
      Otfm is an in-memory decoder for the OpenType font data format. It
      provides low-level access to font tables and functions to decode some
      of them.
    '';

    homepage = webpage;
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.jirkamarsik ];
    mainProgram = "otftrip";
  };
}
