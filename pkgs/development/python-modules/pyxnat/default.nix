{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lxml,
  matplotlib,
  networkx,
  pandas,
  pytest-cov-stub,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyxnat";
  version = "1.6.4";

  # PyPI dist missing test configuration files:
  src = fetchFromGitHub {
    owner = "pyxnat";
    repo = "pyxnat";
    tag = version;
    hash = "sha256-Dhidc5KOzx/S0sr4D7Oc8lvSDT0y8bGDNTAJy/6n8mA=";
  };

  propagatedBuildInputs = [
    lxml
    requests
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    matplotlib
    networkx
    pandas
  ];

  preCheck = ''
    export PYXNAT_SKIP_NETWORK_TESTS=1
  '';

  build-system = [ setuptools ];

  disabledTestPaths = [
    # require a running local XNAT instance e.g. in a docker container:
    "pyxnat/tests/attributes_test.py"
    "pyxnat/tests/custom_variables_test.py"
    "pyxnat/tests/interfaces_test.py"
    "pyxnat/tests/pipelines_test.py"
    "pyxnat/tests/provenance_test.py"
    "pyxnat/tests/prearchive_test.py"
    "pyxnat/tests/repr_test.py"
    "pyxnat/tests/resources_test.py"
    "pyxnat/tests/search_test.py"
    "pyxnat/tests/sessionmirror_test.py"
    "pyxnat/tests/test_resource_functions.py"
    "pyxnat/tests/user_and_project_management_test.py"
  ];

  disabledTests = [
    # try to access network even though PYXNAT_SKIP_NETWORK_TESTS is set:
    "test_inspector_structure"
    "test_project_manager"
  ];

  enabledTestPaths = [ "pyxnat" ];

  # pathlib is installed part of python38+ w/o an external package
  prePatch = ''
    substituteInPlace setup.py --replace-fail "pathlib>=1.0" ""
  '';

  pyproject = true;
  pythonImportsCheck = [ "pyxnat" ];

  meta = {
    description = "Python API to XNAT";
    homepage = "https://pyxnat.github.io/pyxnat";
    changelog = "https://github.com/pyxnat/pyxnat/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ bcdarwin ];
    mainProgram = "sessionmirror.py";
  };
}
