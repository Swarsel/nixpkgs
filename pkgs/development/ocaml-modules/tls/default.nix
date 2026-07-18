{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  domain-name,
  fmt,
  ipaddr,
  kdf,
  logs,
  mirage-crypto,
  mirage-crypto-ec,
  mirage-crypto-pk,
  mirage-crypto-rng,
  ounit2,
  ptime,
  x509,
}:

buildDunePackage (finalAttrs: {
  pname = "tls";
  version = "2.1.0";

  src = fetchurl {
    url = "https://github.com/mirleft/ocaml-tls/releases/download/v${finalAttrs.version}/tls-${finalAttrs.version}.tbz";
    hash = "sha256-2nmWB4n6QYtiv4nNUk6ZgVxQEEE7wYnw8zlmuNC4htI=";
  };

  propagatedBuildInputs = [
    domain-name
    fmt
    logs
    kdf
    mirage-crypto
    mirage-crypto-ec
    mirage-crypto-pk
    mirage-crypto-rng
    ptime
    x509
    ipaddr
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    ounit2
  ];

  meta = {
    description = "TLS in pure OCaml";
    homepage = "https://github.com/mirleft/ocaml-tls";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ sternenseemann ];
  };
})
