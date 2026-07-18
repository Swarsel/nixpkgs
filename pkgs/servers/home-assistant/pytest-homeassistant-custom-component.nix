{
  lib,
  fetchFromGitHub,
  aiohttp,
  bcrypt,
  buildPythonPackage,
  freezegun,
  homeassistant,
  paho-mqtt,
  pytest-asyncio,
  pytest-socket,
  pytestCheckHook,
  pythonOlder,
  requests-mock,
  respx,
  setuptools,
  syrupy,
}:

buildPythonPackage rec {
  pname = "pytest-homeassistant-custom-component";
  version = "0.13.346";

  src = fetchFromGitHub {
    owner = "MatthewFlamm";
    repo = "pytest-homeassistant-custom-component";
    tag = version;
    hash = "sha256-GUUz6gbhmIgZCH9y3oEmf1Y+Gp2yUf8zvxM//uGvsNw=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    bcrypt
    freezegun
    homeassistant
    paho-mqtt
    pytest-asyncio
    pytest-socket
    requests-mock
    respx
    syrupy
  ];

  disabled = pythonOlder "3.13";
  pyproject = true;
  pythonImportsCheck = [ "pytest_homeassistant_custom_component.plugins" ];
  pythonRemoveDeps = true;

  meta = {
    description = "Package to automatically extract testing plugins from Home Assistant for custom component testing";
    homepage = "https://github.com/MatthewFlamm/pytest-homeassistant-custom-component";
    changelog = "https://github.com/MatthewFlamm/pytest-homeassistant-custom-component/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
