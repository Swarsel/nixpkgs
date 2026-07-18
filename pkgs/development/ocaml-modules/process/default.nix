{
  lib,
  stdenv,
  fetchFromGitHub,
  findlib,
  ocaml,
  ocamlbuild,
}:

stdenv.mkDerivation rec {
  pname = "ocaml${ocaml.version}-process";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "dsheets";
    repo = "ocaml-process";
    rev = version;
    sha256 = "0m1ldah5r9gcq09d9jh8lhvr77910dygx5m309k1jm60ah9mdcab";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    ocamlbuild
  ];

  createFindlibDestdir = true;

  meta = {
    inherit (src.meta) homepage;
    inherit (ocaml.meta) platforms;
    description = "Easy process control in OCaml";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };
}
