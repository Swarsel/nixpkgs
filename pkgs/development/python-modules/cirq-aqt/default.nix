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
  pname = "cirq-aqt";

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
  #pythonImportsCheck = [ "cirq_aqt" ];
  disabledTestPaths = [
    # No need to test the version number
    "cirq_aqt/_version_test.py"
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "requests"
  ];

  sourceRoot = "${src.name}/${pname}";
}
