{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "sunwatcher";
  version = "0.2.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-u0vHCw0h0h6pgadBLPBSwv/4CXNj+3HIJCEtt2rdlWs=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "sunwatcher" ];

  meta = {
    description = "Python module for the SolarLog HTTP API";
    homepage = "https://bitbucket.org/Lavode/sunwatcher/src/master/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
