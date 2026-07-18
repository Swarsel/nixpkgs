{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  cstruct,
  ethernet,
  ipaddr,
  logs,
  lru,
  mirage-clock-unix,
  tcpip,
}:

buildDunePackage (finalAttrs: {
  pname = "mirage-nat";
  version = "3.0.2";

  src = fetchurl {
    url = "https://github.com/mirage/mirage-nat/releases/download/v${finalAttrs.version}/mirage-nat-${finalAttrs.version}.tbz";
    hash = "sha256-Z1g3qb26x/S6asYv6roTW77r41SHy7OGN7MoZJ/E8Is=";
  };

  propagatedBuildInputs = [
    ipaddr
    cstruct
    logs
    lru
    tcpip
    ethernet
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    mirage-clock-unix
  ];

  minimalOCamlVersion = "4.08";

  meta = {
    description = "Mirage-nat is a library for network address translation to be used with MirageOS";
    homepage = "https://github.com/mirage/mirage-nat";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
})
