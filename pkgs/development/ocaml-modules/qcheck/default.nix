{ buildDunePackage, qcheck-ounit }:

buildDunePackage {
  inherit (qcheck-ounit) version src patches;
  pname = "qcheck";
  propagatedBuildInputs = [ qcheck-ounit ];

  meta = qcheck-ounit.meta // {
    description = "Compatibility package for qcheck";
  };

}
