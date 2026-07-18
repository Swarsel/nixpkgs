{
  lib,
  buildDunePackage,
  js_of_ocaml,
  js_of_ocaml-ppx,
  lwd,
  tyxml,
}:

buildDunePackage {
  inherit (lwd) version src;
  pname = "tyxml-lwd";
  buildInputs = [ js_of_ocaml-ppx ];

  propagatedBuildInputs = [
    js_of_ocaml
    lwd
    tyxml
  ];

  meta = {
    description = "Make reactive webpages in Js_of_ocaml using Tyxml and Lwd";
    homepage = "https://github.com/let-def/lwd";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.alizter ];
  };
}
