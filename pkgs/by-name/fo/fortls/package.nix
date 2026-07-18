{
  lib,
  fetchFromGitHub,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "fortls";
  version = "3.2.2";

  src = fetchFromGitHub {
    owner = "fortran-lang";
    repo = "fortls";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cUZBr+dtTFbd68z6ts4quIPp9XYMikUBrCq+icrZ1KU=";
  };

  nativeCheckInputs = with python3Packages; [
    pytest-cov-stub
    pytest-xdist
    pytestCheckHook
    versionCheckHook
  ];

  build-system = [ python3Packages.setuptools-scm ];

  dependencies = with python3Packages; [
    json5
    packaging
  ];

  disabledTestPaths = [
    "test/test_server.py"
    "test/test_server_completion.py"
    "test/test_server_definitions.py"
    "test/test_server_diagnostics.py"
    "test/test_server_documentation.py"
    "test/test_server_hover.py"
    "test/test_server_implementation.py"
    "test/test_server_init.py"
    "test/test_server_references.py"
    "test/test_server_rename.py"
    "test/test_server_signature_help.py"
  ];

  disabledTests = [
    "test_hover"
    "test_version_update_pypi"
  ];

  pyproject = true;

  meta = {
    description = "Fortran Language Server";
    homepage = "https://github.com/fortran-lang/fortls";
    license = [ lib.licenses.mit ];
    maintainers = [ lib.maintainers.sheepforce ];
    mainProgram = "fortls";
  };
})
