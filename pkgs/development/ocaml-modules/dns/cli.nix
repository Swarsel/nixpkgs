{
  alcotest,
  bos,
  buildDunePackage,
  cmdliner,
  dns,
  dns-certify,
  dns-client-lwt,
  dns-resolver,
  dns-server,
  dns-tsig,
  dnssec,
  fmt,
  fpath,
  ipaddr,
  logs,
  lwt,
  mirage-crypto,
  mirage-crypto-pk,
  mirage-crypto-rng,
  mirage-mtime,
  mtime,
  ohex,
  ptime,
  randomconv,
  x509,
}:

buildDunePackage {
  inherit (dns) version src;
  pname = "dns-cli";

  # no need to propagate as this is primarily
  # an executable package
  buildInputs = [
    dns
    dns-tsig
    dns-client-lwt
    dns-server
    dns-certify
    dns-resolver
    dnssec
    bos
    cmdliner
    fpath
    x509
    mirage-crypto
    mirage-crypto-pk
    mirage-crypto-rng
    mirage-mtime
    ohex
    ptime
    mtime
    logs
    fmt
    ipaddr
    lwt
    randomconv
  ];

  doCheck = true;

  checkInputs = [
    alcotest
  ];

  meta = dns.meta // {
    description = "Unix command line utilities using uDNS";
    mainProgram = "odns";
  };
}
