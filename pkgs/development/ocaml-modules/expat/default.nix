{
  lib,
  stdenv,
  fetchFromGitHub,
  expat,
  findlib,
  ocaml,
  ounit,
}:

stdenv.mkDerivation rec {
  pname = "ocaml${ocaml.version}-expat";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "whitequark";
    repo = "ocaml-expat";
    rev = "v${version}";
    hash = "sha256-eDA6MUcztaI+fpunWBdanNnPo9Y5gvbj/ViVcxYYEBg=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
  ];

  buildInputs = [ expat ];
  doCheck = lib.versionAtLeast ocaml.version "4.08";
  checkInputs = [ ounit ];
  checkTarget = "testall";
  createFindlibDestdir = true;

  prePatch = ''
    substituteInPlace Makefile --replace "gcc" "\$(CC)"
  '';

  meta = {
    inherit (src.meta) homepage;
    inherit (ocaml.meta) platforms;
    description = "OCaml wrapper for the Expat XML parsing library";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
    broken = !(lib.versionAtLeast ocaml.version "4.02");
  };
}
