{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "kdl-py";
  version = "1.2.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Y/P0bGJ33trc5E3PyUZyv25r8zMLkBIuATTCKFfimXM=";
  };

  checkPhase = ''
    runHook preCheck

    python tests/run.py

    runHook postCheck
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "kdl" ];

  meta = {
    description = "Parser for the KDL language";
    homepage = "https://github.com/tabatkins/kdlpy";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "kdlreformat";
  };
}
