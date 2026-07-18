{
  lib,
  stdenv,
  fetchurl,
  astring,
  bos,
  cmdliner,
  findlib,
  ocaml,
  ocamlbuild,
  rresult,
  topkg,
}:

stdenv.mkDerivation rec {
  inherit (topkg) buildPhase installPhase;
  pname = "ocaml${ocaml.version}-webbrowser";
  version = "0.6.2";

  src = fetchurl {
    url = "https://erratique.ch/software/webbrowser/releases/webbrowser-${version}.tbz";
    sha256 = "sha256-4SYAf1Qo7aUiCp5587wO1VvjcQHP3NBXeFfAaHE/s+A=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    ocamlbuild
    topkg
  ];

  buildInputs = [ topkg ];

  propagatedBuildInputs = [
    astring
    bos
    cmdliner
    rresult
  ];

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Open and reload URIs in browsers from OCaml";
    homepage = "https://erratique.ch/software/webbrowser";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
    mainProgram = "browse";
  };
}
