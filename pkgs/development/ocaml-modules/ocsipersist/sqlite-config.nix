{
  buildDunePackage,
  findlib,
  ocsigen_server,
  ocsipersist-sqlite,
  xml-light,
}:

buildDunePackage {
  inherit (ocsipersist-sqlite) version src;
  pname = "ocsipersist-sqlite-config";

  propagatedBuildInputs = [
    findlib
    ocsipersist-sqlite
    ocsigen_server
    xml-light
  ];

  meta = ocsipersist-sqlite.meta // {
    description = "Ocsigen Server configuration file extension for ocsipersist-sqlite";
  };
}
