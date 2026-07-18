{
  lib,
  buildDunePackage,
  ca-certs,
  conduit-lwt,
  ipaddr,
  ipaddr-sexp,
  logs,
  lwt,
  lwt_log,
  lwt_ssl,
  ppx_sexp_conv,
  ssl,
  uri,
}:

buildDunePackage {
  inherit (conduit-lwt) version src;
  pname = "conduit-lwt-unix";
  buildInputs = [ ppx_sexp_conv ];

  propagatedBuildInputs = [
    conduit-lwt
    lwt
    uri
    ipaddr
    ipaddr-sexp
    ca-certs
    logs
    lwt_ssl
  ];

  doCheck = !lib.versionAtLeast lwt.version "6.0.0";

  checkInputs = [
    lwt_log
    ssl
  ];

  meta = conduit-lwt.meta // {
    description = "Network connection establishment library for Lwt_unix";
  };
}
