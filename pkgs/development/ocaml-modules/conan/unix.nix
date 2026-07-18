{
  alcotest,
  buildDunePackage,
  cachet,
  conan,
  crowbar,
  fmt,
  rresult,
}:

buildDunePackage {
  inherit (conan) version src meta;
  pname = "conan-unix";

  propagatedBuildInputs = [
    cachet
    conan
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    crowbar
    fmt
    rresult
  ];
}
