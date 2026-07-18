{
  lib,
  fetchFromGitHub,
  addBinToPathHook,
  python3Packages,
  versionCheckHook,
}:

let
  pythonPackages = python3Packages.overrideScope (
    self: super: {
      lsprotocol = self.lsprotocol_2023;
      pygls = self.pygls_1;
    }
  );
in
pythonPackages.buildPythonApplication (finalAttrs: {
  pname = "tclint";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "nmoroze";
    repo = "tclint";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HEmNdDq8xeGHCLJRvGGa13KaX7iLyyNkv3nYcJsZjrw=";
  };

  nativeCheckInputs = [
    addBinToPathHook
    pythonPackages.pytestCheckHook
    versionCheckHook
  ];

  build-system = with pythonPackages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with pythonPackages; [
    importlib-metadata
    pathspec
    ply
    pygls
    lsprotocol
    tomli
    voluptuous
  ];

  disabledTestPaths = [
    # Fails to find lsprotocol in the sandbox, even when added to nativeCheckInputs
    # RuntimeError: Client has been stopped.
    # Captured stderr call: ModuleNotFoundError: No module named 'lsprotocol'
    "tests/test_tclsp.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "tclint" ];

  pythonRelaxDeps = [
    "importlib-metadata"
    "pathspec"
    "voluptuous"
  ];

  versionCheckProgramArg = "--version";

  meta = {
    description = "Modern dev tools for Tcl. Includes a linter, formatter, and editor integration";
    homepage = "https://github.com/nmoroze/tclint";
    changelog = "https://github.com/nmoroze/tclint/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    mainProgram = "tclint";
  };
})
