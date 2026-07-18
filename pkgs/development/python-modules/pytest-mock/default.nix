{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pytest-mock";
  version = "3.15.1";

  src = fetchFromGitHub {
    owner = "pytest-dev";
    repo = "pytest-mock";
    tag = "v${version}";
    hash = "sha256-9h5/cssWs4F0LKnFLjWDsEjB2AYczLvnSjiUdsaEcBQ=";
  };

  buildInputs = [ pytest ];

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_mock" ];

  meta = {
    description = "Thin wrapper around the mock package for easier use with pytest";
    homepage = "https://github.com/pytest-dev/pytest-mock";
    changelog = "https://github.com/pytest-dev/pytest-mock/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
