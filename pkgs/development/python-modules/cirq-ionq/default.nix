{
  buildPythonPackage,
  cirq-core,
  pytest-benchmark,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  inherit (cirq-core) version src meta;
  pname = "cirq-ionq";

  nativeCheckInputs = [
    pytest-benchmark
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    cirq-core
    requests
  ];

  # cirq's importlib hook doesn't work here
  #pythonImportsCheck = [ "cirq_ionq" ];
  disabledTestPaths = [
    # No need to test the version number
    "cirq_ionq/_version_test.py"
  ];

  disabledTests = [
    # DeprecationWarning: decompose_to_device was used but is deprecated.
    "test_decompose_operation_deprecated"
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "requests"
  ];

  sourceRoot = "${src.name}/${pname}";
}
