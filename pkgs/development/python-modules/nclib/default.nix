{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "nclib";
  version = "1.0.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-IVnWqHpoYF5bzek0aWWiKtlWiUaX1jcZq+DfLK0FGoI=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "nclib" ];

  meta = {
    description = "Python module that provides netcat features";
    homepage = "https://nclib.readthedocs.io/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "serve-stdio";
  };
}
