{
  lib,
  fetchurl,
  buildDunePackage,
  gen_js_api,
  js_of_ocaml,
  js_of_ocaml-ppx,
  ojs,
  ppxlib,
}:

buildDunePackage (finalAttrs: {
  pname = "promise_jsoo";
  version = "0.3.1";

  src = fetchurl {
    url = "https://github.com/mnxn/promise_jsoo/releases/download/v${finalAttrs.version}/promise_jsoo-v${finalAttrs.version}.tbz";
    sha256 = "00pjnsbv0yv3hhxbbl8dsljgr95kjgi9w8j1x46gjyxg9zayrxzl";
  };

  buildInputs = [
    ppxlib
    js_of_ocaml-ppx
    gen_js_api
  ];

  propagatedBuildInputs = [
    js_of_ocaml
    ojs
  ];

  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Js_of_ocaml bindings to JS Promises with supplemental functions";
    homepage = "https://github.com/mnxn/promise_jsoo";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jayesh-bhoot ];
  };
})
