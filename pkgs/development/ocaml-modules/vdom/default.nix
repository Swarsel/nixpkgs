{
  lib,
  buildDunePackage,
  fetchzip,
  gen_js_api,
  js_of_ocaml-compiler,
  ojs,
}:

buildDunePackage rec {
  pname = "vdom";
  version = "0.3";

  src = fetchzip {
    url = "https://github.com/LexiFi/ocaml-vdom/archive/refs/tags/${version}.tar.gz";
    hash = "sha256-mlXOb+KCdHWNL9PAppan7m7JaP83JEjq+tu14JI+NJo=";
  };

  nativeBuildInputs = [
    gen_js_api
  ];

  buildInputs = [
    gen_js_api
  ];

  propagatedBuildInputs = [
    js_of_ocaml-compiler
    ojs
  ];

  minimalOCamlVersion = "4.08";

  meta = {
    description = "Elm architecture and (V)DOM for OCaml";
    homepage = "https://github.com/LexiFi/ocaml-vdom";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jayesh-bhoot ];
  };
}
