{
  alcotest-lwt,
  astring,
  buildDunePackage,
  cohttp-lwt,
  domain-name,
  fmt,
  h1,
  ipaddr,
  logs,
  lwt,
  mirage-crypto-rng,
  paf,
  tcpip,
  uri,
}:

buildDunePackage {
  inherit (paf)
    version
    src
    ;

  pname = "paf-cohttp";

  propagatedBuildInputs = [
    paf
    cohttp-lwt
    domain-name
    h1
    ipaddr
  ];

  doCheck = true;

  checkInputs = [
    alcotest-lwt
    fmt
    logs
    mirage-crypto-rng
    tcpip
    uri
    lwt
    astring
  ];

  __darwinAllowLocalNetworking = true;

  meta = paf.meta // {
    description = "CoHTTP client with its HTTP/AF implementation";
  };
}
