{
  lib,
  fetchFromGitHub,
  aiohttp,
  async-timeout,
  beautifulsoup4,
  buildHomeAssistantComponent,
  pymodbus,
  pytest-homeassistant-custom-component,
  pytestCheckHook,
  websocket-client,
}:

buildHomeAssistantComponent rec {
  version = "1.0.29";

  src = fetchFromGitHub {
    inherit owner;
    repo = "systemair";
    tag = "v${version}";
    hash = "sha256-qpwF1HZZ8pEDywkFij9ipF3BPFe3oAj8wQKILNuKoHc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-homeassistant-custom-component
  ];

  dependencies = [
    pymodbus
    async-timeout
    aiohttp
    websocket-client
    beautifulsoup4
  ];

  domain = "systemair";

  ignoreVersionRequirement = [
    "pymodbus"
  ];

  owner = "AN3Orik";

  pytestFlags = [
    "-Wignore::pytest.PytestRemovedIn9Warning"
  ];

  meta = {
    description = "Home Assistant component for Systemair SAVE ventilation units";
    homepage = "https://github.com/AN3Orik/systemair";
    changelog = "https://github.com/AN3Orik/systemair/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ uvnikita ];
  };
}
