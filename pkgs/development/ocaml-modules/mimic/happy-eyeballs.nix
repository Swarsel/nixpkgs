{
  lib,
  buildDunePackage,
  dns-client-mirage,
  happy-eyeballs-mirage,
  mimic,
}:

buildDunePackage {
  inherit (mimic) src version;
  pname = "mimic-happy-eyeballs";

  propagatedBuildInputs = [
    dns-client-mirage
    mimic
    happy-eyeballs-mirage
  ];

  doCheck = false;
  minimalOCamlVersion = "4.08";

  meta = {
    inherit (mimic.meta) license homepage;
    description = "Happy-eyeballs integration into mimic";
    maintainers = [ lib.maintainers.ulrikstrid ];
  };
}
