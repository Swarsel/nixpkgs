{
  buildDunePackage,
  js_of_ocaml-compiler,
  ppxlib,
}:

buildDunePackage {
  inherit (js_of_ocaml-compiler) src version;
  pname = "js_of_ocaml-toplevel";
  buildInputs = [ ppxlib ];
  propagatedBuildInputs = [ js_of_ocaml-compiler ];

  meta = js_of_ocaml-compiler.meta // {
    mainProgram = "jsoo_mktop";
  };
}
