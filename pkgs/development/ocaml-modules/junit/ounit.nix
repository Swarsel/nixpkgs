{
  buildDunePackage,
  junit,
  ounit2,
}:

buildDunePackage {
  inherit (junit) src version meta;
  pname = "junit_ounit";

  propagatedBuildInputs = [
    junit
    ounit2
  ];

  doCheck = true;
}
