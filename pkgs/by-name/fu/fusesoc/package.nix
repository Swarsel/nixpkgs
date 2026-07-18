{
  lib,
  fetchPypi,
  gitMinimal,
  gnumake,
  iverilog,
  nix-update-script,
  openssh,
  python3Packages,
  verilator,
  writableTmpDirAsHomeHook,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "fusesoc";
  version = "2.4.6";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-d04DFtV71CkrvX51x19cl0KSn2yOCMmYWGRv3AED8Xw=";
  };

  nativeCheckInputs = [
    gitMinimal
    openssh
    python3Packages.pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    edalize
    pyparsing
    pyyaml
    simplesat
    fastjsonschema
    argcomplete
  ];

  disabledTestPaths = [
    # These tests require network access
    "tests/test_coremanager.py::test_export"
    "tests/test_libraries.py::test_library_add"
    "tests/test_libraries.py::test_library_update_with_initialize"
    "tests/test_provider.py::test_git_provider"
    "tests/test_provider.py::test_github_provider"
    "tests/test_provider.py::test_url_provider"
    "tests/test_usecases.py::test_git_library_with_default_branch_is_added_and_updated"
    "tests/test_usecases.py::test_update_git_library_with_fixed_version"
  ];

  makeWrapperArgs = [
    "--suffix PATH : ${
      lib.makeBinPath [
        iverilog
        verilator
        gnumake
      ]
    }"
  ];

  pyproject = true;
  pythonImportsCheck = [ "fusesoc" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Package manager and build tools for HDL code";
    homepage = "https://github.com/olofk/fusesoc";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ VZstless ];
    mainProgram = "fusesoc";
  };
})
