{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  pytestCheckHook,
  python-lsp-server,
  # dependencies
  rope,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "pylsp-rope";
  version = "0.1.17";

  src = fetchFromGitHub {
    owner = "python-rope";
    repo = "pylsp-rope";
    tag = version;
    hash = "sha256-gEmSZQZ2rtSljN8USsUiqsP2cr54k6kwvsz8cjam9dU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  dependencies = [
    rope
    python-lsp-server
  ];

  pyproject = true;
  pythonImportsCheck = [ "pylsp_rope" ];

  meta = {
    description = "Extended refactoring capabilities for Python LSP Server using Rope";
    homepage = "https://github.com/python-rope/pylsp-rope";
    changelog = "https://github.com/python-rope/pylsp-rope/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
