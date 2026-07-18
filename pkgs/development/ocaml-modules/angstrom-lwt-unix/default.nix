{
  lib,
  angstrom,
  buildDunePackage,
  lwt,
}:

buildDunePackage {
  inherit (angstrom) version src;
  pname = "angstrom-lwt-unix";

  propagatedBuildInputs = [
    angstrom
    lwt
  ];

  doCheck = true;

  meta = {
    inherit (angstrom.meta) homepage license;
    description = "Lwt_unix support for Angstrom";
    maintainers = with lib.maintainers; [ romildo ];
  };
}
