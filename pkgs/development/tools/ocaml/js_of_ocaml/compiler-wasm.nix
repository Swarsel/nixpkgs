{
  lib,
  binaryen,
  buildDunePackage,
  cmdliner,
  js_of_ocaml-compiler,
  menhir,
  menhirLib,
  ppxlib,
  sedlex,
  yojson,
}:

buildDunePackage {
  inherit (js_of_ocaml-compiler) version src;
  pname = "wasm_of_ocaml-compiler";

  nativeBuildInputs = [
    binaryen
    menhir
  ];

  buildInputs = [
    cmdliner
    ppxlib
  ];

  propagatedBuildInputs = [
    js_of_ocaml-compiler
    menhirLib
    sedlex
    yojson
  ];

  dontStrip = true;
  minimalOCamlVersion = "4.12";

  meta = js_of_ocaml-compiler.meta // {
    description = "Compiler from OCaml bytecode to WebAssembly";
    maintainers = [ lib.maintainers.stepbrobd ];
    mainProgram = "wasm_of_ocaml";
  };
}
