{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pycodestyle,
  pytest,
  pytest-isort,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pytest-pycodestyle";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "henry0312";
    repo = "pytest-pycodestyle";
    tag = "v${version}";
    hash = "sha256-X/vacxI0RFHIqlZ2omzvvFDePS/SZYSFQHEmfcbvf/4=";
  };

  buildInputs = [ pytest ];

  nativeCheckInputs = [
    pytest-isort
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ pycodestyle ];
  pyproject = true;
  pythonImportsCheck = [ "pytest_pycodestyle" ];

  meta = {
    description = "Pytest plugin to run pycodestyle";
    homepage = "https://github.com/henry0312/pytest-pycodestyle";
    changelog = "https://github.com/henry0312/pytest-pycodestyle/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
