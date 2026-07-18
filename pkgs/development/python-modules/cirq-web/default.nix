{
  buildPythonPackage,
  cirq-core,
  pytest-benchmark,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  inherit (cirq-core) version src meta;
  pname = "cirq-web";

  nativeCheckInputs = [
    pytest-benchmark
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ cirq-core ];

  # cirq's importlib hook doesn't work here
  #pythonImportsCheck = [ "cirq_web" ];
  disabledTestPaths = [
    # No need to test the version number
    "cirq_web/_version_test.py"
  ];

  pyproject = true;
  sourceRoot = "${src.name}/${pname}";
}
