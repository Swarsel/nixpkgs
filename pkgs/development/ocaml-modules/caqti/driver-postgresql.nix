{
  buildDunePackage,
  caqti,
  postgresql,
}:

buildDunePackage {
  inherit (caqti) version src;
  pname = "caqti-driver-postgresql";

  propagatedBuildInputs = [
    caqti
    postgresql
  ];

  meta = caqti.meta // {
    description = "PostgreSQL driver for Caqti based on C bindings";
  };
}
