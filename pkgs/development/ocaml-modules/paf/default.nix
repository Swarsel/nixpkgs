{
  lib,
  fetchurl,
  alcotest-lwt,
  bigstringaf,
  buildDunePackage,
  cstruct,
  faraday,
  fmt,
  h1,
  h2,
  ke,
  logs,
  lwt,
  mimic,
  mirage-crypto-rng,
  ptime,
  tcpip,
  tls,
  tls-mirage,
  uri,
}:

buildDunePackage (finalAttrs: {
  pname = "paf";
  version = "0.8.0";

  src = fetchurl {
    url = "https://github.com/dinosaure/paf-le-chien/releases/download/${finalAttrs.version}/paf-${finalAttrs.version}.tbz";
    hash = "sha256-0q07gZpzUyDoWlA4m/P+EGSvvVKAZ7RwVkpOziqzG2M=";
  };

  propagatedBuildInputs = [
    h1
    h2
    tls-mirage
    mimic
    ke
    bigstringaf
    faraday
    tls
    cstruct
    tcpip
  ];

  doCheck = true;

  checkInputs = [
    lwt
    logs
    fmt
    mirage-crypto-rng
    ptime
    uri
    alcotest-lwt
  ];

  __darwinAllowLocalNetworking = true;
  minimalOCamlVersion = "4.08";

  meta = {
    description = "HTTP/AF and MirageOS";
    homepage = "https://github.com/dinosaure/paf-le-chien";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
})
