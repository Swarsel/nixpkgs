{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  digestif,
  ohex,
}:

buildDunePackage (finalAttrs: {
  pname = "hkdf";
  version = "2.0.0";

  src = fetchurl {
    url = "https://github.com/hannesm/ocaml-hkdf/releases/download/v${finalAttrs.version}/hkdf-${finalAttrs.version}.tbz";
    hash = "sha256-VLBxJ5viTTn1nK0QNIAGq/8961x0/RGHZN/C/7ITWNM=";
  };

  propagatedBuildInputs = [ digestif ];
  doCheck = true;

  checkInputs = [
    alcotest
    ohex
  ];

  minimalOCamlVersion = "4.08";

  meta = {
    description = "HMAC-based Extract-and-Expand Key Derivation Function (RFC 5869)";
    homepage = "https://github.com/hannesm/ocaml-hkdf";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sternenseemann ];
  };
})
