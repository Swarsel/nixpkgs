{
  buildDunePackage,
  caqti,
  mariadb,
}:

buildDunePackage {
  inherit (caqti) version src;
  pname = "caqti-driver-mariadb";

  propagatedBuildInputs = [
    caqti
    mariadb
  ];

  meta = caqti.meta // {
    description = "MariaDB driver for Caqti using C bindings";
  };
}
