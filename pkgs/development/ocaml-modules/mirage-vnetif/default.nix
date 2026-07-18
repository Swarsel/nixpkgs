{
  lib,
  fetchurl,
  buildDunePackage,
  cstruct,
  duration,
  ipaddr,
  logs,
  lwt,
  macaddr,
  mirage-net,
}:

buildDunePackage (finalAttrs: {
  pname = "mirage-vnetif";
  version = "0.6.2";

  src = fetchurl {
    url = "https://github.com/mirage/mirage-vnetif/releases/download/v${finalAttrs.version}/mirage-vnetif-${finalAttrs.version}.tbz";
    hash = "sha256-SorcrPRhhCYhHasLQGHvTtLo229/3xVB6f7/XOlFRSI=";
  };

  propagatedBuildInputs = [
    lwt
    mirage-net
    cstruct
    ipaddr
    macaddr
    duration
    logs
  ];

  minimalOCamlVersion = "4.06";

  meta = {
    description = "Virtual network interface and software switch for Mirage";
    homepage = "https://github.com/mirage/mirage-vnetif";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
})
