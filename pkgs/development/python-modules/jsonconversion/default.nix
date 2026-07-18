{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pdm-backend,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
}:

buildPythonPackage rec {
  pname = "jsonconversion";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "DLR-RM";
    repo = "python-jsonconversion";
    tag = version;
    hash = "sha256-yWRpILAkwCvgh5bMiN9/XmS6U9zIQdDS8KVeTYxzDDw=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ pdm-backend ];

  dependencies = [
    numpy
    setuptools
  ];

  disabledTests = lib.optionals (pythonAtLeast "3.13") [ "test_dict" ];
  pyproject = true;
  pythonImportsCheck = [ "jsonconversion" ];
  pythonRelaxDeps = [ "numpy" ];

  pythonRemoveDeps = [
    "pytest-runner"
    "pytest"
  ];

  meta = {
    description = "This python module helps converting arbitrary Python objects into JSON strings and back";
    homepage = "https://github.com/DLR-RM/python-jsonconversion";
    changelog = "https://github.com/DLR-RM/python-jsonconversion/releases/tag/${version}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ terlar ];
  };
}
