{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  camlp-streams,
  hex,
  ipaddr,
  ppx_compare,
  ppx_custom_printf,
  ppx_sexp_conv,
  re,
  uuidm,
}:

buildDunePackage (finalAttrs: {
  pname = "pgx";
  version = "2.3";

  src = fetchurl {
    url = "https://github.com/pgx-ocaml/pgx/archive/refs/tags/${finalAttrs.version}.tar.gz";
    hash = "sha256-Rp9PXsWI4cBc1YHD7uqKATrRt5tgNJowbaAFg1aeVKM=";
  };

  propagatedBuildInputs = [
    camlp-streams
    hex
    ipaddr
    ppx_compare
    ppx_custom_printf
    ppx_sexp_conv
    re
    uuidm
  ];

  doCheck = true;
  checkInputs = [ alcotest ];
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Pure-OCaml PostgreSQL client library";
    homepage = "https://github.com/pgx-ocaml/pgx";
    license = lib.licenses.lgpl2Only;
    maintainers = [ lib.maintainers.vog ];
  };
})
