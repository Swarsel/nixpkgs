{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  hatch-vcs,
  hatchling,
  pytestCheckHook,
  pythonAtLeast,
  toolz,
}:

buildPythonPackage rec {
  pname = "in-n-out";
  version = "0.2.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Q83it96YHUGm1wYYore9mJSBCVkipT6tTcdfK71d/+o=";
    pname = "in_n_out";
  };

  nativeCheckInputs = [
    pytestCheckHook
    toolz
  ];

  build-system = [
    cython
    hatchling
    hatch-vcs
  ];

  disabledTestPaths = lib.optionals (pythonAtLeast "3.11") [
    # Fatal Python error
    "tests/test_injection.py"
    "tests/test_processors.py"
    "tests/test_providers.py"
    "tests/test_store.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "in_n_out" ];

  meta = {
    description = "Module for dependency injection and result processing";
    homepage = "https://github.com/pyapp-kit/in-n-out";
    changelog = "https://github.com/pyapp-kit/in-n-out/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
}
