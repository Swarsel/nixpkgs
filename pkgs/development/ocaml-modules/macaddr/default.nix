{
  lib,
  fetchurl,
  buildDunePackage,
  ocaml,
  ounit2,
  ppx_sexp_conv,
}:

buildDunePackage (finalAttrs: {
  pname = "macaddr";
  version = "5.6.2";

  src = fetchurl {
    url = "https://github.com/mirage/ocaml-ipaddr/releases/download/v${finalAttrs.version}/ipaddr-${finalAttrs.version}.tbz";
    hash = "sha256-CKP6bmQRSQtmYeWxAinqnsa4w3OOn2slWFmxPxRb4TY=";
  };

  doCheck = lib.versionAtLeast ocaml.version "4.08";

  checkInputs = [
    ppx_sexp_conv
    ounit2
  ];

  minimalOCamlVersion = "4.04";

  meta = {
    description = "Library for manipulation of MAC address representations";
    homepage = "https://github.com/mirage/ocaml-ipaddr";
    license = lib.licenses.isc;
    maintainers = [ ];
  };
})
