{
  alcotest,
  buildDunePackage,
  conan,
  crowbar,
  fmt,
  rresult,
}:

buildDunePackage {
  inherit (conan) version src;
  pname = "conan-database";
  propagatedBuildInputs = [ conan ];
  doCheck = true;

  checkInputs = [
    alcotest
    crowbar
    fmt
    rresult
  ];

  meta = conan.meta // {
    description = "Database of decision trees to recognize MIME type";
  };
}
