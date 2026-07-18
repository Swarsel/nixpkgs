{
  buildDunePackage,
  caqti,
  logs,
  miou,
}:

buildDunePackage {
  inherit (caqti) version src;
  pname = "caqti-miou";

  propagatedBuildInputs = [
    caqti
    logs
    miou
  ];

  minimalOCamlVersion = "5.1";

  meta = caqti.meta // {
    description = "Miou support for Caqti";
  };
}
