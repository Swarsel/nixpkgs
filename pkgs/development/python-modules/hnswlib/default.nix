{
  buildPythonPackage,
  hnswlib,
  numpy,
  pybind11,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage {
  inherit (hnswlib) version src meta;
  pname = "hnswlib";

  nativeBuildInputs = [
    numpy
    setuptools
    pybind11
  ];

  nativeCheckInputs = [ unittestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "hnswlib" ];

  unittestFlagsArray = [
    "tests/python"
    "--pattern 'bindings_test*.py'"
  ];
}
