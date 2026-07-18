{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "openccu-data";
  version = "2026.6.1";

  src = fetchFromGitHub {
    owner = "SukramJ";
    repo = "openccu-data";
    tag = finalAttrs.version;
    hash = "sha256-iG9TKQQH8wM9sEHfaSPfWwbledwCSS/OlnTZ059l774=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "openccu_data" ];

  meta = {
    description = "Extract and distribute Homematic CCU/OpenCCU configuration metadata";
    homepage = "https://github.com/SukramJ/openccu-data";
    changelog = "https://github.com/SukramJ/openccu-data/blob/${finalAttrs.src.tag}/changelog.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
})
