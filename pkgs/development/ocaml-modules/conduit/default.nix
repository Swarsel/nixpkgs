{
  lib,
  fetchurl,
  astring,
  buildDunePackage,
  ipaddr,
  ipaddr-sexp,
  ppx_sexp_conv,
  sexplib0,
  uri,
}:

buildDunePackage (finalAttrs: {
  pname = "conduit";
  version = "8.0.0";

  src = fetchurl {
    url = "https://github.com/mirage/ocaml-conduit/releases/download/v${finalAttrs.version}/conduit-${finalAttrs.version}.tbz";
    hash = "sha256-CmPZEIZbVHOJOhcM2lH2E4j0iOz0xLLtf+nsTiz2b2E=";
  };

  propagatedBuildInputs = [
    astring
    ipaddr
    ipaddr-sexp
    sexplib0
    uri
    ppx_sexp_conv
  ];

  minimalOCamlVersion = "4.13";

  meta = {
    description = "Network connection establishment library";
    homepage = "https://github.com/mirage/ocaml-conduit";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      vbgl
    ];
  };
})
