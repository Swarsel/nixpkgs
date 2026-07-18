{
  buildDunePackage,
  js_of_ocaml,
  ppxlib,
}:

buildDunePackage {
  inherit (js_of_ocaml) version src meta;
  pname = "js_of_ocaml-ppx_deriving_json";

  propagatedBuildInputs = [
    js_of_ocaml
    ppxlib
  ];
}
