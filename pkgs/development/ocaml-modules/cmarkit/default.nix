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
  pname = "cmarkit";
  version = "0.3.0";

  src = fetchurl {
    url = "https://erratique.ch/software/cmarkit/releases/cmarkit-${version}.tbz";
    hash = "sha256-RouM5iU7VeTT0+4yhBgdEmxROeP/X31iqDjd1VI7z5c=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    ocamlbuild
    topkg
  ];

  buildInputs = [
    topkg
    cmdliner
  ];

  meta = {
    inherit (ocaml.meta) platforms;
    description = "CommonMark parser and renderer for OCaml";
    homepage = "https://erratique.ch/software/cmarkit";
    changelog = "https://github.com/dbuenzli/cmarkit/blob/v${version}/CHANGES.md";
    license = lib.licenses.isc;
    maintainers = [ ];
    broken = lib.versionOlder ocaml.version "4.14.0";
  };
}
