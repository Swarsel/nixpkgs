{
  lib,
  fetchurl,
  alcotest,
  bos,
  buildDunePackage,
  findlib,
  ocaml,
  rresult,
}:

buildDunePackage (finalAttrs: {
  pname = "base64";
  version = "3.5.2";

  src = fetchurl {
    url = "https://github.com/mirage/ocaml-base64/releases/download/v${finalAttrs.version}/base64-${finalAttrs.version}.tbz";
    hash = "sha256-s/XOMBqnLHAy75C+IzLXL/OWKSLADuKuxryt4Yei9Zs=";
  };

  nativeBuildInputs = [ findlib ];
  # otherwise fmt breaks evaluation
  doCheck = lib.versionAtLeast ocaml.version "4.08";

  checkInputs = [
    alcotest
    bos
    rresult
  ];

  minimalOCamlVersion = "4.07";

  meta = {
    description = "Base64 encoding and decoding in OCaml";
    homepage = "https://github.com/mirage/ocaml-base64";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ vbgl ];
  };
})
