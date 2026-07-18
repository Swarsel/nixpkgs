{
  buildDunePackage,
  findlib,
  ocsigen_server,
  ocsipersist-pgsql,
  xml-light,
}:

buildDunePackage {
  inherit (ocsipersist-pgsql) version src;
  pname = "ocsipersist-pgsql-config";

  propagatedBuildInputs = [
    findlib
    ocsipersist-pgsql
    ocsigen_server
    xml-light
  ];

  meta = ocsipersist-pgsql.meta // {
    description = "Ocsigen Server configuration file extension for ocsipersist-pgsql";
  };
}
