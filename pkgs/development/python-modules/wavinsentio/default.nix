{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "wavinsentio";
  version = "0.5.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Xw21JeQA0OMtyATey+LYmf3tRDcSME1bkQeAK0wFhHU=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "wavinsentio" ];

  meta = {
    description = "Python module to interact with the Wavin Sentio underfloor heating system";
    homepage = "https://github.com/djerik/wavinsentio";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
