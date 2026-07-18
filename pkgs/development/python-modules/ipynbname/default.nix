{
  lib,
  buildPythonPackage,
  fetchPypi,
  ipykernel,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ipynbname";
  version = "2025.8.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-3Mg2fGTEqfC6pqzqPlCf1mlr9dgcmrzrOG4q1u/KyTU=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ ipykernel ];
  pyproject = true;
  pythonImportsCheck = [ "ipynbname" ];

  meta = {
    description = "Simply returns either notebook filename or the full path to the notebook";
    homepage = "https://github.com/msm1089/ipynbname";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
