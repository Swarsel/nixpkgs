{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  cmdliner,
  cstruct,
  eio,
  eio_main,
  fmt,
  logs,
  xmlm,
}:

buildDunePackage rec {
  pname = "wayland";
  version = "2.2";

  src = fetchurl {
    url = "https://github.com/talex5/ocaml-wayland/releases/download/v${version}/wayland-${version}.tbz";
    hash = "sha256-D4ggYKTP6UJO05dna44qqpMdhGEL6ynLLsnDVdGBliU=";
  };

  buildInputs = [
    cmdliner
    xmlm
  ];

  propagatedBuildInputs = [
    eio
    logs
    fmt
    cstruct
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    eio_main
  ];

  minimalOCamlVersion = "5.0";

  meta = {
    description = "Pure OCaml Wayland protocol library";
    homepage = "https://github.com/talex5/ocaml-wayland";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sternenseemann ];
    mainProgram = "wayland-scanner-ocaml";
  };
}
