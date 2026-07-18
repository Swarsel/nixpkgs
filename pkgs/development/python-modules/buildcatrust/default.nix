{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "buildcatrust";
  version = "0.5.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-I7f2LCQ8dGFOX/d04mOUll7IL7y5Qn1EPu9UO5496So=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ flit-core ];

  disabledTestPaths = [
    # Non-hermetic, needs internet access (e.g. attempts to retrieve NSS store).
    "buildcatrust/tests/test_nonhermetic.py"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "buildcatrust"
    "buildcatrust.cli"
  ];

  meta = {
    description = "Build SSL/TLS trust stores";
    homepage = "https://github.com/lukegb/buildcatrust";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lukegb ];
    mainProgram = "buildcatrust";
  };
})
