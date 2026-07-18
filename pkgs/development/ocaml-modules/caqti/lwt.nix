{
  buildDunePackage,
  caqti,
  logs,
  lwt,
}:

buildDunePackage {
  inherit (caqti) version src;
  pname = "caqti-lwt";

  propagatedBuildInputs = [
    caqti
    logs
    lwt
  ];

  meta = caqti.meta // {
    description = "Lwt support for Caqti";
  };
}
