{
  lib,
  angstrom,
  async,
  buildDunePackage,
}:

buildDunePackage {
  inherit (angstrom) version src;
  pname = "angstrom-async";

  propagatedBuildInputs = [
    angstrom
    async
  ];

  doCheck = true;
  minimalOCamlVersion = "4.04.1";

  meta = {
    inherit (angstrom.meta) homepage license;
    description = "Async support for Angstrom";
    maintainers = with lib.maintainers; [ romildo ];
  };
}
