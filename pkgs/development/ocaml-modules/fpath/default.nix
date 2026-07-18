{
  lib,
  stdenv,
  fetchurl,
  astring,
  findlib,
  ocaml,
  ocamlbuild,
  topkg,
}:

stdenv.mkDerivation rec {
  inherit (topkg) buildPhase installPhase;
  pname = "ocaml${ocaml.version}-fpath";
  version = "0.7.3";

  src = fetchurl {
    url = "https://erratique.ch/software/fpath/releases/fpath-${version}.tbz";
    sha256 = "03z7mj0sqdz465rc4drj1gr88l9q3nfs374yssvdjdyhjbqqzc0j";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    ocamlbuild
    topkg
  ];

  buildInputs = [ topkg ];
  propagatedBuildInputs = [ astring ];

  meta = {
    inherit (ocaml.meta) platforms;
    description = "OCaml module for handling file system paths with POSIX and Windows conventions";
    homepage = "https://erratique.ch/software/fpath";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
    broken = lib.versionOlder ocaml.version "4.03";
  };
}
