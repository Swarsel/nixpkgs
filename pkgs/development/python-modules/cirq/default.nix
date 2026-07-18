{
  buildPythonPackage,
  # dependencies
  cirq-aqt,
  cirq-core,
  cirq-google,
  cirq-ionq,
  cirq-pasqal,
  cirq-web,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage {
  inherit (cirq-core) version src meta;
  pname = "cirq";
  # pythonImportsCheck = [ "cirq" "cirq.Circuit" ];  # cirq's importlib hook doesn't work here
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    cirq-aqt
    cirq-core
    cirq-google
    cirq-ionq
    cirq-pasqal
    cirq-web
  ];

  # Don't run submodule or development tool tests
  disabledTestPaths = [
    "cirq-aqt"
    "cirq-core"
    "cirq-google"
    "cirq-ionq"
    "cirq-pasqal"
    "cirq-web"
    "dev_tools"
  ];

  pyproject = true;
}
