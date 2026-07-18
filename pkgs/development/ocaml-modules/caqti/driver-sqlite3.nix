{
  alcotest,
  buildDunePackage,
  caqti,
  dune-site,
  ocaml_sqlite3,
}:

buildDunePackage {
  inherit (caqti) version src;
  pname = "caqti-driver-sqlite3";

  propagatedBuildInputs = [
    caqti
    ocaml_sqlite3
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    dune-site
  ];

  meta = caqti.meta // {
    description = "Sqlite3 driver for Caqti using C bindings";
  };
}
