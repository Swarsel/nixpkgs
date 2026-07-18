{
  buildDunePackage,
  cstruct,
  eqaf,
}:

buildDunePackage {
  inherit (eqaf) src version meta;
  pname = "eqaf-cstruct";

  propagatedBuildInputs = [
    cstruct
    eqaf
  ];
}
