{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  home-assistant,
  pytest-asyncio,
  pytestCheckHook,
  python,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "vtherm-api";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "jmcollin78";
    repo = "vtherm_api";
    tag = finalAttrs.version;
    hash = "sha256-8YE9+Y+R6TvBKssRPvDLSdVzonDawWgg01Ngk94eMzM=";
  };

  nativeCheckInputs = [
    home-assistant
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  disabled = python.version != home-assistant.python3Packages.python.version;
  pyproject = true;
  pythonImportsCheck = [ "vtherm_api" ];

  meta = {
    description = "API for Versatile Thermostat Home Assistant integrations";
    homepage = "https://github.com/jmcollin78/vtherm_api";
    changelog = "https://github.com/jmcollin78/vtherm_api/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ geri1701 ];
  };
})
