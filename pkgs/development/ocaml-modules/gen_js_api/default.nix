{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  js_of_ocaml-compiler,
  nodejs,
  ocaml,
  ojs,
  ppxlib,
}:

buildDunePackage (finalAttrs: {
  pname = "gen_js_api";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "LexiFi";
    repo = "gen_js_api";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-baK+/y0s08hHC8/+P7RKOboFnALQpndxBMuhI1WKf2o=";
  };

  propagatedBuildInputs = [
    ojs
    ppxlib
  ];

  doCheck = lib.versionAtLeast ocaml.version "4.13" && !(lib.versionAtLeast ppxlib.version "0.36");

  nativeCheckInputs = [
    js_of_ocaml-compiler
    nodejs
  ];

  minimalOCamlVersion = "4.11";

  meta = {
    description = "Easy OCaml bindings for JavaScript libraries";

    longDescription = ''
      gen_js_api aims at simplifying the creation of OCaml bindings for
      JavaScript libraries. Authors of bindings write OCaml signatures for
      JavaScript libraries and the tool generates the actual binding code with a
      combination of implicit conventions and explicit annotations.

      gen_js_api is to be used with the js_of_ocaml compiler.
    '';

    homepage = "https://github.com/LexiFi/gen_js_api";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.bcc32 ];
  };
})
