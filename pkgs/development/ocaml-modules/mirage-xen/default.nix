{
  lib,
  fetchurl,
  bheap,
  buildDunePackage,
  cstruct,
  duration,
  fmt,
  io-page,
  logs,
  lwt,
  lwt-dllist,
  mirage-profile,
  mirage-runtime,
  shared-memory-ring-lwt,
  xenstore,
}:

buildDunePackage (finalAttrs: {
  pname = "mirage-xen";
  version = "8.0.1";

  src = fetchurl {
    url = "https://github.com/mirage/mirage-xen/releases/download/v${finalAttrs.version}/mirage-xen-${finalAttrs.version}.tbz";
    hash = "sha256-x8i2Kbz0EcifZK/lbDIFa9Kwtl1/xzbYV9h9E+EtGP4=";
  };

  propagatedBuildInputs = [
    cstruct
    lwt
    shared-memory-ring-lwt
    xenstore
    lwt-dllist
    mirage-profile
    mirage-runtime
    io-page
    logs
    fmt
    bheap
    duration
  ];

  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Xen core platform libraries for MirageOS";
    homepage = "https://github.com/mirage/mirage-xen";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
})
