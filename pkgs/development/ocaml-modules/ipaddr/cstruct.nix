{
  buildDunePackage,
  cstruct,
  ipaddr,
}:

buildDunePackage {
  inherit (ipaddr) version src;
  pname = "ipaddr-cstruct";

  propagatedBuildInputs = [
    ipaddr
    cstruct
  ];

  doCheck = true;
  duneVersion = "3";

  meta = ipaddr.meta // {
    description = "Library for manipulation of IP address representations using Cstructs";
  };
}
