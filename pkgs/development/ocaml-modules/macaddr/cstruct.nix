{
  buildDunePackage,
  cstruct,
  macaddr,
}:

buildDunePackage {
  inherit (macaddr) version src;
  pname = "macaddr-cstruct";

  propagatedBuildInputs = [
    macaddr
    cstruct
  ];

  doCheck = true;
  duneVersion = "3";

  meta = macaddr.meta // {
    description = "Library for manipulation of MAC address representations using Cstructs";
  };
}
