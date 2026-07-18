{
  buildDunePackage,
  ounit2,
  qcheck-core,
}:

buildDunePackage {
  inherit (qcheck-core) version src;
  pname = "qcheck-ounit";

  propagatedBuildInputs = [
    qcheck-core
    ounit2
  ];

  meta = qcheck-core.meta // {
    description = "OUnit backend for qcheck";
  };

}
