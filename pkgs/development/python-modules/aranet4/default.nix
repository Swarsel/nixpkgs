{
  lib,
  fetchFromGitHub,
  bleak,
  buildPythonPackage,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aranet4";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "Anrijs";
    repo = "Aranet4-Python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9dVa2RCsA+cs0fA8rLaOnikedEDz6fSfQ1tfAV0A7Eo=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    bleak
    requests
  ];

  disabledTests = [
    # Test compares rendered output
    "test_current_values"
  ];

  pyproject = true;
  pythonImportsCheck = [ "aranet4" ];

  meta = {
    description = "Module to interact with Aranet4 devices";
    homepage = "https://github.com/Anrijs/Aranet4-Python";
    changelog = "https://github.com/Anrijs/Aranet4-Python/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "aranetctl";
  };
})
