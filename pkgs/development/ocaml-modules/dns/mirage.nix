{
  buildDunePackage,
  cstruct,
  dns,
  ipaddr,
  lwt,
  tcpip,
}:

buildDunePackage {
  inherit (dns) version src;
  pname = "dns-mirage";

  propagatedBuildInputs = [
    cstruct
    dns
    ipaddr
    lwt
    tcpip
  ];

  meta = dns.meta // {
    description = "Opinionated Domain Name System (DNS) library";
  };
}
