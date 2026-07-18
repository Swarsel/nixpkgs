{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pytestCheckHook,
  pythonAtLeast,
}:

buildPythonPackage rec {
  pname = "mypy-extensions";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "python";
    repo = "mypy_extensions";
    tag = version;
    hash = "sha256-HNAFsWX4tU9hfZkKxLNJn1J+H3uTesQflbRPlo3GQ4k=";
  };

  # make the testsuite run with pytest, so we can disable individual tests
  nativeCheckInputs = [ pytestCheckHook ];
  dependencies = [ flit-core ];

  disabledTests = lib.optionals (pythonAtLeast "3.14") [
    # https://github.com/python/mypy_extensions/issues/65
    "test_py36_class_syntax_usage"
  ];

  enabledTestPaths = [ "tests/testextensions.py" ];
  pyproject = true;
  pythonImportsCheck = [ "mypy_extensions" ];

  meta = {
    description = "Experimental type system extensions for programs checked with the mypy typechecker";
    homepage = "https://www.mypy-lang.org";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
