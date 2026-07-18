{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  domain_shims,
  js_of_ocaml,
  nodejs-slim,
}:

buildDunePackage (finalAttrs: {
  pname = "multicore-magic";
  version = "2.3.2";

  src = fetchurl {
    url = "https://github.com/ocaml-multicore/multicore-magic/releases/download/${finalAttrs.version}/multicore-magic-${finalAttrs.version}.tbz";
    hash = "sha256-jY1wqCOq4c4EMDgIQqqIHErIONJFyvJ+0P8ld1CHF18=";
  };

  doCheck = true;

  nativeCheckInputs = [
    nodejs-slim
    js_of_ocaml
  ];

  checkInputs = [
    alcotest
    domain_shims
  ];

  meta = {
    description = "Low-level multicore utilities for OCaml";
    homepage = "https://github.com/ocaml-multicore/multicore-magic";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
