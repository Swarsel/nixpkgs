{
  lib,
  angstrom,
  buildDunePackage,
}:

buildDunePackage {
  inherit (angstrom) version src;
  pname = "angstrom-unix";
  propagatedBuildInputs = [ angstrom ];
  doCheck = true;

  meta = {
    inherit (angstrom.meta) homepage license;
    description = "Unix support for Angstrom";
    maintainers = with lib.maintainers; [ romildo ];
  };
}
