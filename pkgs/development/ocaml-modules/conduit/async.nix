{
  async,
  buildDunePackage,
  conduit,
  core,
  ipaddr,
  ipaddr-sexp,
  ppx_here,
  ppx_sexp_conv,
  sexplib0,
  uri,
  async_ssl ? null,
}:

buildDunePackage {
  inherit (conduit)
    version
    src
    ;

  pname = "conduit-async";

  buildInputs = [
    ppx_sexp_conv
    ppx_here
  ];

  propagatedBuildInputs = [
    async
    async_ssl
    conduit
    uri
    ipaddr
    ipaddr-sexp
    core
    sexplib0
  ];

  meta = conduit.meta // {
    description = "Network connection establishment library for Async";
  };
}
