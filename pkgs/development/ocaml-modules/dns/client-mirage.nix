{
  buildDunePackage,
  ca-certs-nss,
  dns,
  dns-client,
  domain-name,
  happy-eyeballs,
  happy-eyeballs-mirage,
  ipaddr,
  lwt,
  mirage-crypto-rng,
  mirage-mtime,
  mirage-ptime,
  mirage-sleep,
  tcpip,
  tls-mirage,
}:

buildDunePackage {
  inherit (dns) src version;
  pname = "dns-client-mirage";

  propagatedBuildInputs = [
    dns-client
    domain-name
    ipaddr
    lwt
    mirage-crypto-rng
    mirage-sleep
    mirage-mtime
    mirage-ptime
    ca-certs-nss
    happy-eyeballs
    happy-eyeballs-mirage
    tcpip
    tls-mirage
  ];

  doCheck = true;
  meta = dns-client.meta;
}
