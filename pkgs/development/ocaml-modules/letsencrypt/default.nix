{
  lib,
  fetchurl,
  base64,
  buildDunePackage,
  digestif,
  domain-name,
  fmt,
  logs,
  lwt,
  mirage-crypto,
  mirage-crypto-ec,
  mirage-crypto-pk,
  ounit2,
  ptime,
  uri,
  x509,
  yojson,
}:

buildDunePackage (finalAttrs: {
  pname = "letsencrypt";
  version = "1.1.0";

  src = fetchurl {
    url = "https://github.com/mmaker/ocaml-letsencrypt/releases/download/v${finalAttrs.version}/letsencrypt-${finalAttrs.version}.tbz";
    hash = "sha256-Iw55GffyG5tWA49hao1z9BX6p4N2+EKuhLIoOwG8EKM=";
  };

  buildInputs = [
    fmt
    ptime
    domain-name
  ];

  propagatedBuildInputs = [
    logs
    yojson
    lwt
    base64
    digestif
    mirage-crypto
    mirage-crypto-ec
    mirage-crypto-pk
    x509
    uri
  ];

  doCheck = true;
  checkInputs = [ ounit2 ];
  minimalOCamlVersion = "4.08";

  meta = {
    description = "ACME implementation in OCaml";
    homepage = "https://github.com/mmaker/ocaml-letsencrypt";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
})
