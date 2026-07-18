{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest,
  pytestCheckHook,
  setuptools,
  six,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytest-assume";
  version = "2.4.3";

  src = fetchFromGitHub {
    owner = "astraw38";
    repo = "pytest-assume";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QIwETun/n8SnBzK/axWiVTcuWiJ0ph3+2pQYVRMmVWI=";
  };

  buildInputs = [ pytest ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ six ];
  pyproject = true;
  pythonImportsCheck = [ "pytest_assume" ];

  meta = {
    description = "Pytest plugin that allows multiple failures per test";
    homepage = "https://github.com/astraw38/pytest-assume";
    changelog = "https://github.com/astraw38/pytest-assume/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jfr ];
  };
})
