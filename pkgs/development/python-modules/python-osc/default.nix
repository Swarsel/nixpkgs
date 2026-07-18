{
  lib,
  buildPythonPackage,
  fetchPypi,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-osc";
  version = "1.9.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-vQ+kDe9DzlCYlHCf6w4Y8CGSrKGSxebI/iumnljyF5Q=";
    pname = "python_osc";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pythonosc" ];

  meta = {
    description = "Open Sound Control server and client in pure python";
    homepage = "https://github.com/attwad/python-osc";
    changelog = "https://github.com/attwad/python-osc/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ anirrudh ];
  };
}
