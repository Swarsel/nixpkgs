{
  buildDunePackage,
  qcheck-multicoretests-util,
}:

buildDunePackage {
  inherit (qcheck-multicoretests-util) src version;
  pname = "qcheck-stm";
  propagatedBuildInputs = [ qcheck-multicoretests-util ];
  doCheck = true;

  meta = qcheck-multicoretests-util.meta // {
    description = "State-machine testing library for sequential and parallel model-based tests";
  };
}
