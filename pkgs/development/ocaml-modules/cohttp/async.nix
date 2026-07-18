{
  lib,
  async,
  async_kernel,
  async_unix,
  base,
  buildDunePackage,
  cohttp,
  conduit-async,
  core,
  digestif,
  fmt,
  ipaddr,
  logs,
  magic-mime,
  mirage-crypto,
  ounit,
  ppx_sexp_conv,
  sexplib0,
  uri,
  uri-sexp,
  core_unix ? null,
}:

buildDunePackage {
  inherit (cohttp)
    version
    src
    ;

  pname = "cohttp-async";
  buildInputs = [ ppx_sexp_conv ];

  propagatedBuildInputs = [
    cohttp
    conduit-async
    async_kernel
    async_unix
    async
    base
    core_unix
    magic-mime
    logs
    fmt
    sexplib0
    uri
    uri-sexp
    ipaddr
  ];

  doCheck = true;

  checkInputs = [
    ounit
    core
    digestif
  ]
  ++ lib.optionals (lib.versionOlder cohttp.version "6.0.0") [
    mirage-crypto
  ];

  minimalOCamlVersion = if lib.versionOlder cohttp.version "6.0.0" then "4.14" else "5.1";

  meta = cohttp.meta // {
    description = "CoHTTP implementation for the Async concurrency library";
  };
}
