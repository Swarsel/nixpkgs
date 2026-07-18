{
  alcotest,
  base64,
  buildDunePackage,
  dns,
  domain-name,
  logs,
  mirage-crypto,
  mirage-crypto-ec,
  mirage-crypto-pk,
}:

buildDunePackage {
  inherit (dns) version src;
  pname = "dnssec";

  propagatedBuildInputs = [
    dns
    mirage-crypto
    mirage-crypto-pk
    mirage-crypto-ec
    domain-name
    logs
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    base64
  ];

  meta = dns.meta // {
    description = "DNSSec support for OCaml-DNS";
  };
}
