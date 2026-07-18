{
  lib,
  buildDunePackage,
  fmt,
  lun,
  ppxlib,
}:

buildDunePackage {
  inherit (lun) version src;
  pname = "ppx_lun";

  propagatedBuildInputs = [
    lun
    ppxlib
  ];

  doCheck = true;
  checkInputs = [ fmt ];

  meta = lun.meta // {
    description = "Optics with lun package and PPX";
    license = lib.licenses.mit;
  };
}
