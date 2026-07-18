{
  lib,
  bitlist,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "fountains";
  version = "3.0.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-gGYmHvlD9cmivPtM/2sKW36FvUzk5FxYBgZfLUX2lIg=";
  };

  # Module has no test
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ bitlist ];
  pyproject = true;
  pythonImportsCheck = [ "fountains" ];

  meta = {
    description = "Python library for generating and embedding data for unit testing";
    homepage = "https://github.com/reity/fountains";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
