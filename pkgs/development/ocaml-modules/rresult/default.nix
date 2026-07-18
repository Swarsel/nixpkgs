{
  lib,
  stdenv,
  fetchurl,
  findlib,
  ocaml,
  ocamlbuild,
  result,
  topkg,
}:

stdenv.mkDerivation rec {
  inherit (topkg) buildPhase installPhase;
  pname = "ocaml${ocaml.version}-rresult";
  version = "0.7.0";

  src = fetchurl {
    url = "https://erratique.ch/software/rresult/releases/rresult-${version}.tbz";
    sha256 = "sha256-Eap/W4NGDmBDHjFU4+MsBx1G4VHqV2DPJDd4Bb+XVUA=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    ocamlbuild
    topkg
  ];

  buildInputs = [ topkg ];
  propagatedBuildInputs = [ result ];

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Result value combinators for OCaml";
    homepage = "https://erratique.ch/software/rresult";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
    broken = !(lib.versionAtLeast ocaml.version "4.07");
  };
}
