{
  buildDunePackage,
  js_of_ocaml,
  js_of_ocaml-ppx,
  reactivedata,
  tyxml,
}:

buildDunePackage {
  inherit (js_of_ocaml) version src meta;
  pname = "js_of_ocaml-tyxml";
  buildInputs = [ js_of_ocaml-ppx ];

  propagatedBuildInputs = [
    js_of_ocaml
    reactivedata
    tyxml
  ];
}
