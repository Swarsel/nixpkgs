{
  lib,
  buildPythonPackage,
  fetchFromSourcehut,
  hatchling,
  pook,
  pytest,
  pytestCheckHook,
}:

buildPythonPackage {
  pname = "pytest-pook";
  version = "1.0.0";

  src = fetchFromSourcehut {
    owner = "~sara";
    repo = "pytest-pook";
    rev = "a7c2d0ca4287af671ebd065b0f6415bb4110f338";
    hash = "sha256-q2HaoIB2CW5LaRggLlmar2AEa4X8cI/aY2Sz/Y7LWMs=";
  };

  buildInputs = [
    pytest
  ];

  # fails in various ways
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    (pook.overridePythonAttrs { doCheck = false; })
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pytest_pook"
  ];

  meta = {
    description = "Pytest plugin for pook";
    homepage = "https://git.sr.ht/~sara/pytest-pook";
    license = lib.licenses.lgpl3Only;
    maintainers = pook.meta.maintainers;
  };
}
