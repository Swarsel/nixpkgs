{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  ohex,
  ptime,
}:

buildDunePackage (finalAttrs: {
  pname = "asn1-combinators";
  version = "0.3.2";

  src = fetchurl {
    url = "https://github.com/mirleft/ocaml-asn1-combinators/releases/download/v${finalAttrs.version}/asn1-combinators-${finalAttrs.version}.tbz";
    hash = "sha256-KyaYX24nIgc9zZ+ENVvWdX4SZDtaSOMLPAf/fPsNin8=";
  };

  propagatedBuildInputs = [ ptime ];
  doCheck = true;

  checkInputs = [
    alcotest
    ohex
  ];

  minimalOCamlVersion = "4.13.0";

  meta = {
    description = "Combinators for expressing ASN.1 grammars in OCaml";
    homepage = "https://github.com/mirleft/ocaml-asn1-combinators";
    changelog = "https://github.com/mirleft/ocaml-asn1-combinators/blob/v${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ vbgl ];
  };
})
