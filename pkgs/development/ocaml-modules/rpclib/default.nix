{
  lib,
  fetchurl,
  alcotest,
  base64,
  buildDunePackage,
  cmdliner,
  rresult,
  xmlm,
  yojson,
}:

buildDunePackage (finalAttrs: {
  pname = "rpclib";
  version = "10.2.0";

  src = fetchurl {
    url = "https://github.com/mirage/ocaml-rpc/releases/download/${finalAttrs.version}/rpclib-${finalAttrs.version}.tbz";
    hash = "sha256-N+xKTdU/yy042EZBXTpFl21aeMFTHm2HbbJDbpRxcvM=";
  };

  buildInputs = [
    cmdliner
    yojson
  ];

  propagatedBuildInputs = [
    base64
    rresult
    xmlm
  ];

  doCheck = true;
  checkInputs = [ alcotest ];
  minimalOCamlVersion = "4.14";

  meta = {
    description = "Light library to deal with RPCs in OCaml";
    homepage = "https://github.com/mirage/ocaml-rpc";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vyorkin ];
  };
})
