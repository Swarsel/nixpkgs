{
  alcotest,
  base64,
  buildDunePackage,
  digestif,
  dns,
}:

buildDunePackage {
  inherit (dns) version src;
  pname = "dns-tsig";

  propagatedBuildInputs = [
    digestif
    dns
    base64
  ];

  doCheck = true;

  checkInputs = [
    alcotest
  ];

  meta = dns.meta // {
    description = "TSIG support for DNS";
  };
}
