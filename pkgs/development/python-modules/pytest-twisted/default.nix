{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  decorator,
  greenlet,
  pytest,
  pytestCheckHook,
  setuptools,
  twisted,
}:

buildPythonPackage rec {
  pname = "pytest-twisted";
  version = "1.14.3";

  src = fetchFromGitHub {
    owner = "pytest-dev";
    repo = "pytest-twisted";
    tag = "v${version}";
    hash = "sha256-1dAfCa6hON0Vh9StI1Xw69IAwBzUkR6DdjQ0HNyoyME=";
  };

  buildInputs = [ pytest ];

  nativeCheckInputs = [
    pytestCheckHook
    twisted
  ];

  build-system = [ setuptools ];

  dependencies = [
    decorator
    greenlet
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_twisted" ];

  meta = {
    description = "Twisted plugin for py.test";
    homepage = "https://github.com/pytest-dev/pytest-twisted";
    changelog = "https://github.com/pytest-dev/pytest-twisted/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
