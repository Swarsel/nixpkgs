{
  buildDunePackage,
  logs,
  ocsipersist,
  pgocaml,
  xml-light,
}:

buildDunePackage {
  inherit (ocsipersist) version src;
  pname = "ocsipersist-pgsql";

  propagatedBuildInputs = [
    logs
    ocsipersist
    pgocaml
  ];

  meta = ocsipersist.meta // {
    description = "Persistent key/value storage for OCaml using PostgreSQL";
  };
}
