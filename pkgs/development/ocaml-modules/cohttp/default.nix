{
  lib,
  fetchurl,
  alcotest,
  base64,
  buildDunePackage,
  crowbar,
  fmt,
  http,
  ipaddr,
  jsonm,
  logs,
  ocaml,
  ppx_sexp_conv,
  re,
  stringext,
  uri-sexp,
}:

buildDunePackage (finalAttrs: {
  pname = "cohttp";
  version = if lib.versionAtLeast ocaml.version "4.13" then "6.2.1" else "5.3.1";

  src = fetchurl {
    url = "https://github.com/mirage/ocaml-cohttp/releases/download/v${finalAttrs.version}/cohttp-${finalAttrs.version}.tbz";

    hash =
      {
        "5.3.1" = "sha256-9eJz08Lyn/R71+Ftsj4fPWzQGkC+ACCJhbxDTIjUV2s=";
        "6.2.1" = "sha256-ZQgCR3Y0QtHcPNkGeLgjO3mHcvA2rIHNHqreH11mpl8=";
      }
      ."${finalAttrs.version}";
  };

  postPatch = ''
    substituteInPlace cohttp/src/dune --replace 'bytes base64' 'base64'
  '';

  buildInputs = [
    ppx_sexp_conv
  ]
  ++ lib.optionals (lib.versionOlder finalAttrs.version "6.0.0") [
    jsonm
  ];

  propagatedBuildInputs = [
    base64
    re
    stringext
    uri-sexp
  ]
  ++ lib.optionals (lib.versionAtLeast finalAttrs.version "6.0.0") [
    http
    ipaddr
    logs
  ];

  doCheck = true;

  checkInputs = [
    fmt
    alcotest
  ]
  ++ lib.optionals (lib.versionOlder finalAttrs.version "6.0.0") [
    crowbar
  ];

  minimalOCamlVersion = "4.08";

  meta = {
    description = "HTTP(S) library for Lwt, Async and Mirage";
    homepage = "https://github.com/mirage/ocaml-cohttp";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
