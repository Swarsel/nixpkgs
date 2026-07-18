{
  buildDunePackage,
  dns,
  dns-tsig,
  domain-name,
  fmt,
  letsencrypt,
  logs,
  lwt,
}:

buildDunePackage {
  inherit (letsencrypt)
    version
    src
    ;

  pname = "letsencrypt-dns";

  propagatedBuildInputs = [
    letsencrypt
    dns
    dns-tsig
    domain-name
    logs
    lwt
    fmt
  ];

  minimalOCamlVersion = "4.08";

  meta = letsencrypt.meta // {
    description = "DNS solver for the ACME implementation in OCaml";
  };
}
