{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:
buildPythonPackage rec {
  pname = "pre-commit-po-hooks";
  version = "1.7.3";

  src = fetchFromGitHub {
    owner = "mondeja";
    repo = "pre-commit-po-hooks";
    rev = "v${version}";
    hash = "sha256-wTmcV8KkoQLuK4EWDt0pbp+EQJRatxnQYeBfikK+vlA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pre_commit_po_hooks" ];

  meta = {
    description = "Hooks for pre-commit useful working with PO files";
    homepage = "https://github.com/mondeja/pre-commit-po-hooks";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ yajo ];
  };
}
