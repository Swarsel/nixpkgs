{
  alcotest,
  base64,
  buildDunePackage,
  dns,
  dns-mirage,
  dns-tsig,
  duration,
  lwt,
  metrics,
  mirage-crypto-rng,
  mirage-mtime,
  mirage-ptime,
  mirage-sleep,
  randomconv,
}:

buildDunePackage {
  inherit (dns) version src;
  pname = "dns-server";

  propagatedBuildInputs = [
    dns
    dns-mirage
    randomconv
    duration
    lwt
    mirage-sleep
    mirage-mtime
    mirage-ptime
    metrics
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    mirage-crypto-rng
    dns-tsig
    base64
  ];

  meta = dns.meta // {
    description = "DNS server, primary and secondary";
  };
}
