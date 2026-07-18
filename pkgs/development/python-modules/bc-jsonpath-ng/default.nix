{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  decorator,
  ply,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "bc-jsonpath-ng";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "bridgecrewio";
    repo = "jsonpath-ng";
    tag = finalAttrs.version;
    hash = "sha256-FWP4tzlacAWVXG3YnPwl5MKc12geaCxZ2xyKx9PSarU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    decorator
    ply
  ];

  disabledTestPaths = [
    # Exclude tests that require oslotest
    "tests/test_jsonpath_rw_ext.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "bc_jsonpath_ng" ];

  meta = {
    description = "JSONPath implementation for Python";
    homepage = "https://github.com/bridgecrewio/jsonpath-ng";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "bc_jsonpath_ng";
  };
})
