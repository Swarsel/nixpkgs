{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pytest-plus";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "pytest-dev";
    repo = "pytest-plus";
    tag = "v${version}";
    hash = "sha256-XlEtekOASIjZretTbQAf0eyQN6qZ9c6zI1ESss/hxfI=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  enabledTestPaths = [ "test/" ];
  pyproject = true;
  pythonImportsCheck = [ "pytest_plus" ];

  meta = {
    description = "pytest-plus adds new features to pytest";
    homepage = "https://github.com/pytest-dev/pytest-plus";
    changelog = "https://github.com/pytest-dev/pytest-plus/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ robsliwi ];
  };
}
