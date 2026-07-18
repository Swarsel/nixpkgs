{
  lib,
  fetchurl,
  alcotest,
  asn1-combinators,
  base64,
  buildDunePackage,
  domain-name,
  fmt,
  gmap,
  ipaddr,
  kdf,
  logs,
  mirage-crypto,
  mirage-crypto-ec,
  mirage-crypto-pk,
  ohex,
}:

buildDunePackage (finalAttrs: {
  pname = "x509";
  version = "1.1.1";

  src = fetchurl {
    url = "https://github.com/mirleft/ocaml-x509/releases/download/v${finalAttrs.version}/x509-${finalAttrs.version}.tbz";
    hash = "sha256-trFZ3Fa6RcNzAn8g5gd5te+Nb7eFTotCio3Zr+FAylU=";
  };

  propagatedBuildInputs = [
    asn1-combinators
    domain-name
    fmt
    gmap
    mirage-crypto
    mirage-crypto-pk
    mirage-crypto-ec
    kdf
    logs
    base64
    ipaddr
    ohex
  ];

  doCheck = true;
  checkInputs = [ alcotest ];

  meta = {
    description = "X509 (RFC5280) handling in OCaml";
    homepage = "https://github.com/mirleft/ocaml-x509";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
})
