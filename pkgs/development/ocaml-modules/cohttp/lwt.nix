{
  lib,
  buildDunePackage,
  cohttp,
  ipaddr,
  logs,
  lwt,
  ppx_sexp_conv,
  sexplib0,
  uri,
}:

buildDunePackage {
  inherit (cohttp)
    version
    src
    ;

  pname = "cohttp-lwt";
  buildInputs = [ ppx_sexp_conv ];

  propagatedBuildInputs = [
    cohttp
    lwt
    logs
    sexplib0
    uri
  ]
  ++ lib.optionals (lib.versionAtLeast cohttp.version "6.0.0") [
    ipaddr
  ];

  meta = cohttp.meta // {
    description = "CoHTTP implementation using the Lwt concurrency library";
  };
}
