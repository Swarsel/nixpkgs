{
  buildDunePackage,
  logs,
  ocaml_sqlite3,
  ocsigen_server,
  ocsipersist,
}:

buildDunePackage {
  inherit (ocsipersist) version src;
  pname = "ocsipersist-sqlite";

  propagatedBuildInputs = [
    logs
    ocaml_sqlite3
    ocsipersist
  ];

  meta = ocsipersist.meta // {
    description = "Persistent key/value storage for OCaml using SQLite";
  };
}
