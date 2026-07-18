{
  lib,
  stdenv,
  fetchurl,
  findlib,
  ocaml,
}:

stdenv.mkDerivation {
  pname = "ocaml-cryptgps";
  version = "0.2.1";

  src = fetchurl {
    url = "http://download.camlcity.org/download/cryptgps-0.2.1.tar.gz";
    sha256 = "1mp7i42cm9w9grmcsa69m3h1ycpn6a48p43y4xj8rsc12x9nav3s";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
  ];

  createFindlibDestdir = true;
  dontConfigure = true; # Skip configure phase

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Cryptographic functions for OCaml";

    longDescription = ''
      This library implements the symmetric cryptographic algorithms
      Blowfish, DES, and 3DES. The algorithms are written in O'Caml,
      i.e. this is not a binding to some C library, but the implementation
      itself.
    '';

    homepage = "http://projects.camlcity.org/projects/cryptgps.html";
    license = lib.licenses.mit;
    broken = lib.versionAtLeast ocaml.version "4.06";
  };
}
