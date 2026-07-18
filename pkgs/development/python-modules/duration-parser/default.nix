{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "duration-parser";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "adriansahlman";
    repo = "duration-parser";
    tag = "v${version}";
    hash = "sha256-Vn3H2JEMrJ6b/7eNG+h9tG5QzslGvaV3sunM7UO9Bok=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  pyproject = true;

  pythonImportsCheck = [
    "duration_parser"
  ];

  meta = {
    description = "Minimal duration parser written in python";
    homepage = "https://github.com/adriansahlman/duration-parser";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
