{
  buildDunePackage,
  dns,
  dns-client-mirage,
  dns-mirage,
  dns-resolver,
  dns-server,
  dns-tsig,
  duration,
  lwt,
  metrics,
  mirage-crypto-rng,
  mirage-ptime,
  randomconv,
  tcpip,
}:

buildDunePackage {
  inherit (dns) version src;
  pname = "dns-stub";

  propagatedBuildInputs = [
    dns
    dns-client-mirage
    dns-mirage
    dns-resolver
    dns-tsig
    dns-server
    duration
    randomconv
    lwt
    mirage-ptime
    mirage-crypto-rng
    tcpip
    metrics
  ];

  doCheck = true;

  meta = dns.meta // {
    description = "DNS stub resolver";
  };
}
