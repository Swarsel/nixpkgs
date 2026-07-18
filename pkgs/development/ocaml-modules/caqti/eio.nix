{
  buildDunePackage,
  caqti,
  eio,
  logs,
}:

buildDunePackage {
  inherit (caqti) version src;
  pname = "caqti-eio";

  propagatedBuildInputs = [
    caqti
    logs
    eio
  ];

  minimalOCamlVersion = "5.1";

  meta = caqti.meta // {
    description = "Eio support for Caqti";
  };
}
