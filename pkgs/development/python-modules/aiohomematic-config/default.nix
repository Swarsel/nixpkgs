{
  lib,
  fetchFromGitHub,
  aiohomematic,
  buildPythonPackage,
  openccu-data,
  pydantic,
  pytest-asyncio,
  pytest-xdist,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiohomematic-config";
  version = "2026.5.0";

  src = fetchFromGitHub {
    owner = "sukramj";
    repo = "aiohomematic-config";
    tag = finalAttrs.version;
    hash = "sha256-uBIdBpjkEIPyuNxTEgTVc068K8UIVvdBXvwZ1MYh7rs=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-xdist
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohomematic
    openccu-data
    pydantic
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiohomematic_config" ];

  meta = {
    description = "Presentation-layer library for Homematic device configuration UI";
    homepage = "https://github.com/sukramj/aiohomematic-config";
    changelog = "https://github.com/sukramj/aiohomematic-config/blob/${finalAttrs.src.tag}/changelog.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
})
