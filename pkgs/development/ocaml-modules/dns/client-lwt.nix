{
  alcotest,
  buildDunePackage,
  ca-certs,
  dns,
  dns-client,
  happy-eyeballs,
  happy-eyeballs-lwt,
  ipaddr,
  lwt,
  mirage-crypto-rng,
  mtime,
  tls-lwt,
}:

buildDunePackage {
  inherit (dns) src version;
  pname = "dns-client-lwt";

  propagatedBuildInputs = [
    dns
    dns-client
    ipaddr
    lwt
    ca-certs
    happy-eyeballs
    happy-eyeballs-lwt
    tls-lwt
    mtime
    mirage-crypto-rng
  ];

  doCheck = true;
  checkInputs = [ alcotest ];
  meta = dns-client.meta;
}
