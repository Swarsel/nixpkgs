{
  lib,
  alcotest,
  buildDunePackage,
  hex,
  ppx_deriving,
  ppxlib,
  repr,
}:

buildDunePackage {
  inherit (repr) src version;
  pname = "ppx_repr";

  propagatedBuildInputs = [
    ppx_deriving
    ppxlib
    repr
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    hex
  ];

  meta = repr.meta // {
    description = "PPX deriver for type representations";
  };
}
