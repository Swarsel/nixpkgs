{
  alcotest,
  buildDunePackage,
  ca-certs,
  cohttp,
  eio,
  eio_main,
  fmt,
  http,
  logs,
  ptime,
  tls-eio,
  uri,
}:

buildDunePackage {
  inherit (cohttp)
    version
    src
    ;

  pname = "cohttp-eio";

  propagatedBuildInputs = [
    cohttp
    eio
    fmt
    http
    logs
    ptime
    uri
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    ca-certs
    eio_main
    tls-eio
  ];

  minimalOCamlVersion = "5.1";

  meta = cohttp.meta // {
    description = "CoHTTP implementation with eio backend";
  };
}
