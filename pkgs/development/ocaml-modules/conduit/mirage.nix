{
  buildDunePackage,
  ca-certs-nss,
  conduit-lwt,
  cstruct,
  dns-client-mirage,
  ipaddr,
  ipaddr-sexp,
  mirage-crypto-rng,
  mirage-flow,
  mirage-flow-combinators,
  mirage-mtime,
  mirage-ptime,
  ppx_sexp_conv,
  sexplib0,
  tcpip,
  tls,
  tls-mirage,
  uri,
  vchan,
  xenstore,
}:

buildDunePackage {
  inherit (conduit-lwt) version src;
  pname = "conduit-mirage";
  nativeBuildInputs = [ ppx_sexp_conv ];

  propagatedBuildInputs = [
    sexplib0
    uri
    cstruct
    mirage-ptime
    mirage-mtime
    mirage-flow
    mirage-flow-combinators
    mirage-crypto-rng
    dns-client-mirage
    conduit-lwt
    vchan
    xenstore
    tls
    tls-mirage
    ipaddr
    ipaddr-sexp
    tcpip
    ca-certs-nss
  ];

  meta = conduit-lwt.meta // {
    description = "Network connection establishment library for MirageOS";
  };
}
