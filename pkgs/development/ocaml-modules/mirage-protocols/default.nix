{
  lib,
  fetchurl,
  arp,
  buildDunePackage,
  ethernet,
  ipaddr,
  tcpip,
}:

buildDunePackage (finalAttrs: {
  pname = "mirage-protocols";
  version = "8.0.0";

  src = fetchurl {
    url = "https://github.com/mirage/mirage-protocols/releases/download/v${finalAttrs.version}/mirage-protocols-v${finalAttrs.version}.tbz";
    hash = "sha256-UDCR4Jq3tw9P/Ilw7T4+3+yi9Q7VFqnHhXeSCvg9dyw=";
  };

  propagatedBuildInputs = [
    arp
    ethernet
    ipaddr
    tcpip
  ];

  duneVersion = "3";

  meta = {
    description = "MirageOS signatures for network protocols";
    homepage = "https://github.com/mirage/mirage-protocols";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
