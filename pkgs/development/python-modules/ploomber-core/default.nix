{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  posthog,
  pytestCheckHook,
  pythonAtLeast,
  pyyaml,
  setuptools,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "ploomber-core";
  version = "0.2.27";

  src = fetchFromGitHub {
    owner = "ploomber";
    repo = "core";
    tag = finalAttrs.version;
    hash = "sha256-/HlJxaxsGbZ1UIJNwDdzJLR4bey7bv/qsmFmVi8eWjQ=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    pyyaml
    posthog
    typing-extensions
  ];

  disabledTestPaths = lib.optionals (pythonAtLeast "3.14") [
    # Depends on pre-3.14 attribute access
    "tests/test_config.py"
  ];

  disabledTests = [
    "telemetry" # requires network
    "exceptions" # requires stderr capture
  ];

  pyproject = true;
  pythonImportsCheck = [ "ploomber_core" ];

  meta = {
    description = "Core module shared across Ploomber projects";
    homepage = "https://github.com/ploomber/core";
    changelog = "https://github.com/ploomber/core/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ euxane ];
  };
})
