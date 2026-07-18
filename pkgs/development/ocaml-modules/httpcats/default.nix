{
  lib,
  alcotest,
  bstr,
  buildDunePackage,
  ca-certs,
  digestif,
  dns-client-miou-unix,
  fetchpatch2,
  fetchzip,
  fmt,
  h1,
  h2,
  happy-eyeballs-miou-unix,
  logs,
  mirage-crypto-rng-miou-unix,
  tls-miou-unix,
}:

buildDunePackage (finalAttrs: {
  pname = "httpcats";
  version = "0.2.1";

  src = fetchzip {
    url = "https://github.com/robur-coop/httpcats/releases/download/v${finalAttrs.version}/httpcats-${finalAttrs.version}.tbz";
    hash = "sha256-ehtwxQGHw8igzI0dy2Zzs+VOqvck/tAUuuJl+jSpVU8=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-6zXPb+mvw2rcEMv28b0npcL8cKl3CASxDbl7FOAGsXs=";
      url = "https://github.com/robur-coop/httpcats/commit/d8787555d4831e0488780d42bd2c65de662d1d38.patch";
    })
  ];

  propagatedBuildInputs = [
    h2
    h1
    ca-certs
    bstr
    tls-miou-unix
    dns-client-miou-unix
    happy-eyeballs-miou-unix
  ];

  doCheck = true;

  checkInputs = [
    logs
    fmt
    mirage-crypto-rng-miou-unix
    alcotest
    digestif
  ];

  __darwinAllowLocalNetworking = true;

  meta = {
    description = "A simple HTTP client / server using h1, h2, and miou";
    homepage = "https://github.com/robur-coop/httpcats/";
    changelog = "https://github.com/robur-coop/httpcats/blob/v${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ rpqt ];
  };
})
