{
  buildDunePackage,
  csv,
  lwt,
}:

buildDunePackage {
  inherit (csv) src version meta;
  pname = "csv-lwt";

  propagatedBuildInputs = [
    csv
    lwt
  ];

  preConfigure = ''
    substituteInPlace lwt/dune --replace '(libraries   bytes' '(libraries '
  '';

  doCheck = true;
  duneVersion = "3";
}
