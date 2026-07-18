{
  buildDunePackage,
  dns,
  dns-mirage,
  dns-tsig,
  logs,
  lwt,
  mirage-crypto-ec,
  mirage-crypto-pk,
  mirage-crypto-rng,
  mirage-ptime,
  mirage-sleep,
  randomconv,
  tcpip,
  x509,
}:

buildDunePackage {
  inherit (dns) version src;
  pname = "dns-certify";

  propagatedBuildInputs = [
    dns
    dns-tsig
    dns-mirage
    randomconv
    x509
    mirage-sleep
    mirage-ptime
    logs
    mirage-crypto-pk
    mirage-crypto-rng
    mirage-crypto-ec
    lwt
    tcpip
  ];

  doCheck = true;

  meta = dns.meta // {
    description = "MirageOS let's encrypt certificate retrieval";
  };
}
