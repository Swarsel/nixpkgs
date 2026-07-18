{
  alcotest,
  buildDunePackage,
  qcheck-core,
}:

buildDunePackage {
  inherit (qcheck-core) version src;
  pname = "qcheck-alcotest";

  propagatedBuildInputs = [
    qcheck-core
    alcotest
  ];

  meta = qcheck-core.meta // {
    description = "Alcotest backend for qcheck";
  };
}
