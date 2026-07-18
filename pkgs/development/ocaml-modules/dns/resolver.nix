{
  alcotest,
  buildDunePackage,
  ca-certs-nss,
  dns,
  dns-mirage,
  dns-server,
  dnssec,
  duration,
  lru,
  lwt,
  mirage-crypto-rng,
  mirage-mtime,
  mirage-ptime,
  mirage-sleep,
  randomconv,
  tcpip,
  tls,
  tls-mirage,
}:

buildDunePackage {
  inherit (dns) version src;
  pname = "dns-resolver";

  propagatedBuildInputs = [
    dns
    dns-server
    dns-mirage
    dnssec
    lru
    duration
    randomconv
    lwt
    mirage-sleep
    mirage-mtime
    mirage-ptime
    mirage-crypto-rng
    tcpip
    tls
    tls-mirage
    ca-certs-nss
  ];

  doCheck = true;

  checkInputs = [
    alcotest
  ];

  meta = dns.meta // {
    description = "DNS resolver business logic";
  };
}
