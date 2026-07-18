{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatchling,
  # dependencies
  pytest,
  # tests
  pytestCheckHook,
  rich,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytest-pretty";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "samuelcolvin";
    repo = "pytest-pretty";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vJ75zpY0xlTQbi7qTHyqHZ7AMb7bLlM6SNq2b7zcQYs=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    pytest
    rich
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_pretty" ];

  meta = {
    description = "Pytest plugin for pretty printing the test summary";
    homepage = "https://github.com/samuelcolvin/pytest-pretty";
    changelog = "https://github.com/samuelcolvin/pytest-pretty/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
