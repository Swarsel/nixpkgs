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
  pname = "ocaml-react";
  version = "1.2.2";

  src = fetchurl {
    url = "https://erratique.ch/software/react/releases/react-${version}.tbz";
    sha256 = "sha256-xK3TFdbx8VPRFe58qN1gwSZf9NQIwmYSX8tRJP0ij5k=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    ocamlbuild
  ];

  buildInputs = [ topkg ];

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Applicative events and signals for OCaml";
    homepage = "https://erratique.ch/software/react";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      gal_bolle
    ];
  };
}
