{
  buildDunePackage,
  dolmen,
  spelll,
  uutf,
}:

buildDunePackage {
  inherit (dolmen) src version;
  pname = "dolmen_type";

  propagatedBuildInputs = [
    dolmen
    spelll
    uutf
  ];

  meta = dolmen.meta // {
    description = "Typechecker for automated deduction languages";
  };
}
