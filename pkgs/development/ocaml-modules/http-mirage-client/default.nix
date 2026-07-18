{
  lib,
  fetchurl,
  alcotest-lwt,
  buildDunePackage,
  h1,
  h2,
  mimic-happy-eyeballs,
  mirage-crypto-rng,
  paf,
  tcpip,
  x509,
}:

buildDunePackage (finalAttrs: {
  pname = "http-mirage-client";
  version = "0.0.10";

  src = fetchurl {
    url = "https://github.com/robur-coop/http-mirage-client/releases/download/v${finalAttrs.version}/http-mirage-client-${finalAttrs.version}.tbz";
    hash = "sha256-AXEIH1TIAayD4LkFv0yGD8OYvcdC/AJnGudGlkjcWLY=";
  };

  propagatedBuildInputs = [
    h2
    h1
    mimic-happy-eyeballs
    paf
    tcpip
    x509
  ];

  doCheck = true;

  checkInputs = [
    alcotest-lwt
    mirage-crypto-rng
  ];

  __darwinAllowLocalNetworking = true;
  minimalOCamlVersion = "4.08";

  meta = {
    description = "HTTP client for MirageOS";
    homepage = "https://github.com/robur-coop/http-mirage-client";
    changelog = "https://github.com/robur-coop/http-mirage-client/blob/v${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
