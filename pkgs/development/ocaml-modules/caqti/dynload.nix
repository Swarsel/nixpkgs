{
  buildDunePackage,
  caqti,
  findlib,
}:

buildDunePackage {
  inherit (caqti) version src;
  pname = "caqti-dynload";

  propagatedBuildInputs = [
    caqti
    findlib
  ];

  meta = caqti.meta // {
    description = "Dynamic linking of Caqti drivers using findlib.dynload";
  };
}
