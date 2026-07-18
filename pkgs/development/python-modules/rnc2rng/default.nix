{
  lib,
  buildPythonPackage,
  fetchPypi,
  python,
  rply,
}:

buildPythonPackage rec {
  pname = "rnc2rng";
  version = "2.7.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-3Z/7vWnQnLB+bnqM+A/ShwP9xtO5Am+HVrScvjMUZ2s=";
  };

  propagatedBuildInputs = [ rply ];
  checkPhase = "${python.interpreter} test.py";
  format = "setuptools";

  meta = {
    description = "Compact to regular syntax conversion library for RELAX NG schemata";
    homepage = "https://github.com/djc/rnc2rng";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
    mainProgram = "rnc2rng";
  };
}
