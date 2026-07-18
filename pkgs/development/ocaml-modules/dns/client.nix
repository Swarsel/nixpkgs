{
  alcotest,
  buildDunePackage,
  dns,
  domain-name,
  mirage-crypto-rng,
  mtime,
  randomconv,
}:

buildDunePackage {
  inherit (dns) src version;
  pname = "dns-client";

  propagatedBuildInputs = [
    dns
    randomconv
    domain-name
    mtime
    mirage-crypto-rng
  ];

  doCheck = true;
  checkInputs = [ alcotest ];

  meta = dns.meta // {
    description = "Pure DNS resolver API";
    mainProgram = "dns-client.unix";
  };
}
