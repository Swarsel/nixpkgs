{
  lib,
  fetchurl,
  buildDunePackage,
  io-page,
  ipaddr,
  logs,
  lwt,
  lwt-dllist,
  macaddr,
  mirage-net,
  mirage-profile,
  mirage-xen,
  ppx_cstruct,
  ppx_sexp_conv,
  result,
  sexplib,
  shared-memory-ring,
}:

buildDunePackage (finalAttrs: {
  pname = "netchannel";
  version = "2.1.3";

  src = fetchurl {
    url = "https://github.com/mirage/mirage-net-xen/releases/download/v${finalAttrs.version}/mirage-net-xen-${finalAttrs.version}.tbz";
    hash = "sha256-gOpzY4bn9L8wkbeViXy/XQmxKqqJfd99bcHQFitYFOE=";
  };

  buildInputs = [
    ppx_cstruct
  ];

  propagatedBuildInputs = [
    ppx_sexp_conv
    lwt
    mirage-net
    io-page
    mirage-xen
    ipaddr
    mirage-profile
    shared-memory-ring
    sexplib
    logs
    macaddr
    lwt-dllist
    result
  ];

  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Network device for reading and writing Ethernet frames via then Xen netfront/netback protocol";
    homepage = "https://github.com/mirage/mirage-net-xen";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
})
