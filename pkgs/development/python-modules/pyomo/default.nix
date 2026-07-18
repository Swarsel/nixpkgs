{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  parameterized,
  ply,
  pybind11,
  pytestCheckHook,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "pyomo";
  version = "6.9.5";

  src = fetchFromGitHub {
    owner = "pyomo";
    repo = "pyomo";
    tag = version;
    hash = "sha256-DHA/OukSK1p65imJEZg7hbErJGL7aQiDbW4vUUuSEko=";
  };

  nativeCheckInputs = [
    parameterized
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = [
    cython
    pybind11
    setuptools
  ];

  dependencies = [ ply ];

  disabledTestPaths = [
    # Don't test the documentation and the examples
    "doc/"
    "examples/"
    # Tests don't work properly in the sandbox
    "pyomo/environ/tests/test_environ.py"
  ];

  disabledTests = [
    # Test requires lsb_release
    "test_get_os_version"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyomo" ];

  meta = {
    description = "Python Optimization Modeling Objects";
    homepage = "http://www.pyomo.org/";
    changelog = "https://github.com/Pyomo/pyomo/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "pyomo";
  };
}
