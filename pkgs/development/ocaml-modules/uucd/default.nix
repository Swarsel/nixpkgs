{
  lib,
  stdenv,
  fetchurl,
  findlib,
  ocaml,
  ocamlbuild,
  topkg,
  xmlm,
}:

let
  pname = "uucd";
  webpage = "https://erratique.ch/software/${pname}";
  version = "17.0.0";
in
stdenv.mkDerivation {
  inherit version;
  inherit (topkg) buildPhase installPhase;
  pname = "ocaml${ocaml.version}-${pname}";

  src = fetchurl {
    url = "${webpage}/releases/${pname}-${version}.tbz";
    hash = "sha256-ifjEBUN+Lqw4W9FeoGX4XBjnxcJL15ukd+aSSDS8KC0=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    ocamlbuild
    topkg
  ];

  buildInputs = [ topkg ];
  propagatedBuildInputs = [ xmlm ];

  meta = {
    inherit (ocaml.meta) platforms;
    description = "OCaml module to decode the data of the Unicode character database from its XML representation";
    homepage = webpage;
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.vbgl ];
  };
}
