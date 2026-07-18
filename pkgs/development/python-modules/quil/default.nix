{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pytestCheckHook,
  rustPlatform,
  syrupy,
}:

buildPythonPackage rec {
  pname = "quil";
  version = "0.35.0";

  src = fetchFromGitHub {
    owner = "rigetti";
    repo = "quil-rs";
    tag = "quil-rs/v${version}";
    hash = "sha256-QWW8+cup81eyedDTU3jgslNanaj0+D2jI5XQMS3ZUIo=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  nativeCheckInputs = [
    pytestCheckHook
    syrupy
  ];

  buildAndTestSubdir = "quil-rs";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-cIWnTuxoFqkl+0W6NH9DwNokq7RKdNggFLwPYgkbHho=";
  };

  dependencies = [ numpy ];
  pyproject = true;

  pytestFlags = [
    "quil-rs/tests_py"
  ];

  pythonImportsCheck = [
    "quil.expression"
    "quil.instructions"
    "quil.program"
    "quil.validation"
  ];

  meta = {
    description = "Python package for building and parsing Quil programs";
    homepage = "https://github.com/rigetti/quil-rs/tree/main/quil-py";
    changelog = "https://github.com/rigetti/quil-rs/blob/${src.tag}/quil-rs/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
