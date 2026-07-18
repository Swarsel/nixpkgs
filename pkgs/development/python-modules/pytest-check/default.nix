{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  pytest,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pytest-check";
  version = "2.8.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-xC4I3dQa2cOHvRbvpmSt5d7016pcYHsFup4l9aq6cMI=";
    pname = "pytest_check";
  };

  buildInputs = [ pytest ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "pytest_check" ];

  meta = {
    description = "Pytest plugin allowing multiple failures per test";
    homepage = "https://github.com/okken/pytest-check";
    changelog = "https://github.com/okken/pytest-check/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ flokli ];
  };
}
