{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pytest,
  pytestCheckHook,
  pythonAtLeast,
}:

buildPythonPackage rec {
  pname = "virtual-glob";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "chrisjsewell";
    repo = "virtual-glob";
    tag = "v${version}";
    hash = "sha256-ocCa8m7mPPvzOZHPrraSEdSJZwRJoYO/Q7nyDbhIFu8=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    flit-core
  ];

  disabledTests = lib.optionals (pythonAtLeast "3.13") [
    "test_baseline_pathlib"
  ];

  optional-dependencies = {
    testing = [
      pytest
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "virtual_glob"
  ];

  meta = {
    description = "Globbing of virtual file systems";
    homepage = "https://pypi.org/project/virtual_glob/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ PopeRigby ];
  };
}
