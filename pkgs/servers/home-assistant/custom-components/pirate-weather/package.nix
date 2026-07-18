{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  nix-update-script,
  pytest-asyncio,
  pytest-homeassistant-custom-component,
  # Test dependencies
  pytestCheckHook,
}:

buildHomeAssistantComponent rec {
  version = "1.8.9";

  src = fetchFromGitHub {
    inherit owner;
    repo = "pirate-weather-ha";
    tag = "v${version}";
    hash = "sha256-QcTRLQ/jFH3lacnFu/cIGyAf74HaoG35iGKf8FQIlVo=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-homeassistant-custom-component
    pytest-asyncio
  ];

  domain = "pirateweather";
  owner = "Pirate-Weather";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Replacement for the default Dark Sky Home Assistant integration using Pirate Weather";
    homepage = "https://github.com/Pirate-Weather/pirate-weather-ha";
    changelog = "https://github.com/Pirate-Weather/pirate-weather-ha/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ CodedNil ];
  };
}
