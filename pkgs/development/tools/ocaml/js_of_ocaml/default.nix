{
  buildDunePackage,
  js_of_ocaml-compiler,
  ppxlib,
}:

buildDunePackage {
  inherit (js_of_ocaml-compiler) version src;
  pname = "js_of_ocaml";
  buildInputs = [ ppxlib ];
  propagatedBuildInputs = [ js_of_ocaml-compiler ];
  meta = removeAttrs js_of_ocaml-compiler.meta [ "mainProgram" ];
}
