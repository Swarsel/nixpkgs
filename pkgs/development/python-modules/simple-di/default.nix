{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "simple-di";
  version = "0.1.5";

  src = fetchPypi {
    inherit version;
    hash = "sha256-GSuZne5M1PsRpdhhFlyq0C2PBhfA+Ab8Wwn5BfGgPKA=";
    pname = "simple_di";
  };

  propagatedBuildInputs = [
    setuptools
    typing-extensions
  ];

  # pypi distribution contains no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "simple_di" ];

  meta = {
    description = "Simple dependency injection library";
    homepage = "https://github.com/bentoml/simple_di";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ sauyon ];
  };
}
