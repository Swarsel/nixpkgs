{
  lib,
  astring,
  bash,
  buildDunePackage,
  cmdliner,
  cppo,
  fmt,
  fpath,
  jq,
  markup,
  ocaml-crunch,
  odoc-parser,
  ppx_expect,
  result,
  sexplib0,
  tyxml,
  yojson,
}:

buildDunePackage {
  inherit (odoc-parser) version src;
  pname = "odoc";

  nativeBuildInputs = [
    cppo
    ocaml-crunch
  ];

  buildInputs = [
    astring
    cmdliner
    fpath
    tyxml
    odoc-parser
    fmt
  ];

  doCheck = true;

  nativeCheckInputs = [
    bash
    jq
  ];

  checkInputs = [
    markup
    yojson
    sexplib0
    jq
    ppx_expect
  ];

  preCheck = ''
    # some run.t files check the content of patchShebangs-ed scripts, so patch
    # them as well
    find test \( -name '*.sh' -o -name 'run.t' \)  -execdir sed 's@#!/bin/sh@#!${bash}/bin/sh@' -i '{}' \;
    patchShebangs test
  '';

  meta = {
    description = "Documentation generator for OCaml";
    homepage = "https://github.com/ocaml/odoc";
    changelog = "https://github.com/ocaml/odoc/blob/${odoc-parser.version}/CHANGES.md";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
    mainProgram = "odoc";
  };
}
