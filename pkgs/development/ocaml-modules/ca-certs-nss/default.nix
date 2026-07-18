{
  lib,
  fetchurl,
  alcotest,
  bos,
  buildDunePackage,
  cmdliner,
  digestif,
  fmt,
  logs,
  mirage-ptime,
  x509,
}:

buildDunePackage (finalAttrs: {
  pname = "ca-certs-nss";
  version = "3.125";

  src = fetchurl {
    url = "https://github.com/mirage/ca-certs-nss/releases/download/v${finalAttrs.version}/ca-certs-nss-${finalAttrs.version}.tbz";
    hash = "sha256-mF0XgW/8YiZjDSaAjloI6cIEGJbEuclYitZ6kAmyWWQ=";
  };

  buildInputs = [
    logs
    fmt
    bos
    cmdliner
  ];

  propagatedBuildInputs = [
    mirage-ptime
    x509
    digestif
  ];

  doCheck = true;
  checkInputs = [ alcotest ];
  minimalOCamlVersion = "4.13";

  meta = {
    description = "X.509 trust anchors extracted from Mozilla's NSS";
    homepage = "https://github.com/mirage/ca-certs-nss";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sternenseemann ];
    mainProgram = "extract-from-certdata";
  };
})
