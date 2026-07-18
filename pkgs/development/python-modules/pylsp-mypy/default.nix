{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  mypy,
  pytestCheckHook,
  python-lsp-server,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pylsp-mypy";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "python-lsp";
    repo = "pylsp-mypy";
    tag = finalAttrs.version;
    hash = "sha256-rS0toZaAygNJ3oe3vfP9rKJ1A0avIdp5yjNx7oGOB4o=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    mypy
    python-lsp-server
  ];

  disabledTests = [
    # Tests wants to call dmypy
    "test_option_overrides_dmypy"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pylsp_mypy" ];

  meta = {
    description = "Mypy plugin for the Python LSP Server";
    homepage = "https://github.com/python-lsp/pylsp-mypy";
    changelog = "https://github.com/python-lsp/pylsp-mypy/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cpcloud ];
  };
})
