{
  buildDunePackage,
  dns,
  dns-client,
  domain-name,
  happy-eyeballs,
  happy-eyeballs-miou-unix,
  ipaddr,
  miou,
  tls-miou-unix,
}:

buildDunePackage {
  inherit (dns) src version;
  pname = "dns-client-miou-unix";

  propagatedBuildInputs = [
    dns-client
    domain-name
    ipaddr
    miou
    tls-miou-unix
    happy-eyeballs
    happy-eyeballs-miou-unix
  ];

  doCheck = true;

  meta = dns-client.meta // {
    description = "DNS client API for Miou";
  };
}
