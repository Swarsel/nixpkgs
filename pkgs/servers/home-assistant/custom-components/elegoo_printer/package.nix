{
  lib,
  fetchFromGitHub,
  aiohttp,
  # dependencies
  aiomqtt,
  buildHomeAssistantComponent,
  colorlog,
  home-assistant,
  loguru,
  # tests
  pytestCheckHook,
  websocket-client,
  websockets,
}:

buildHomeAssistantComponent rec {
  version = "2.10.2";

  src = fetchFromGitHub {
    owner = "danielcherubini";
    repo = "elegoo-homeassistant";
    tag = "v${version}";
    hash = "sha256-+bL43ACj/8dI7dNVNQ+3n2WvDaYhuh3tiwX98yXmTm4=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    aiohttp
    home-assistant
  ];

  dependencies = [
    aiomqtt
    colorlog
    loguru
    websocket-client
    websockets
  ];

  domain = "elegoo_printer";
  owner = "danielcherubini";

  meta = {
    description = "Home Assistant integration for Elegoo 3D printers using the SDCP protocol";
    homepage = "https://github.com/danielcherubini/elegoo-homeassistant";
    changelog = "https://github.com/danielcherubini/elegoo-homeassistant/releases/tag/v${version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      typedrat
    ];
  };
}
