{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest,
  pytest-describe,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytest-spec";
  version = "6.1.0";

  src = fetchFromGitHub {
    owner = "pchomik";
    repo = "pytest-spec";
    tag = finalAttrs.version;
    hash = "sha256-9kJLIe2msS2DrpEerSOa9rh3XfBJQMfY7wwrtH3XQn0=";
  };

  buildInputs = [ pytest ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-describe
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_spec" ];

  meta = {
    description = "Pytest plugin to display test execution output like a SPECIFICATION";
    homepage = "https://github.com/pchomik/pytest-spec";
    changelog = "https://github.com/pchomik/pytest-spec/blob/${finalAttrs.src.rev}/CHANGES.txt";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ tomasajt ];
  };
})
