{
  alcotest,
  bstr,
  buildDunePackage,
  conan,
  crowbar,
  fmt,
  lwt,
  rresult,
}:

buildDunePackage {
  inherit (conan) version src meta;
  pname = "conan-lwt";

  propagatedBuildInputs = [
    conan
    lwt
    bstr
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    crowbar
    fmt
    rresult
  ];
}
