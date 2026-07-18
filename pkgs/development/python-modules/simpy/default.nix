{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  py,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "simpy";
  version = "4.1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-BtB1CniEsR4OjiDOC8fG1O1fF0PUVmlTQNE/3/lQAaY=";
  };

  nativeCheckInputs = [
    py
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  disabledTests =
    lib.optionals (pythonAtLeast "3.13") [
      # Failing on python >= 3.13
      # FAILED tests/test_exceptions.py::test_exception_chaining - AssertionError: Traceback mismatch
      "test_exception_chaining"
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      "test_rt"
      "test_rt_multiple_call"
      "test_rt_slow_sim_no_error"
    ];

  enabledTestPaths = [
    "tests"
  ];

  pyproject = true;
  pythonImportsCheck = [ "simpy" ];

  meta = {
    description = "Process-based discrete-event simulation framework based on standard Python";
    homepage = "https://simpy.readthedocs.io/en/${version}/";
    license = [ lib.licenses.mit ];

    maintainers = with lib.maintainers; [
      shlevy
    ];

    downloadPage = "https://github.com/simpx/simpy";
  };
}
