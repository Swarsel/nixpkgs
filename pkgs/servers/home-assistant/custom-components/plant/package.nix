{
  lib,
  fetchFromGitHub,
  async-timeout,
  buildHomeAssistantComponent,
  pytest-freezer,
  pytest-homeassistant-custom-component,
  pytestCheckHook,
}:

buildHomeAssistantComponent rec {
  version = "2026.6.0";

  src = fetchFromGitHub {
    inherit owner;
    repo = "homeassistant-plant";
    tag = "v${version}";
    hash = "sha256-WdUL4ne/sewIbdXpCbrpFMglIQA3qdvwSVuaww4lQYM=";
  };

  nativeCheckInputs = [
    pytest-freezer
    pytest-homeassistant-custom-component
    pytestCheckHook
  ];

  dependencies = [
    async-timeout
  ];

  domain = "plant";
  owner = "olen";

  meta = {
    description = "Alternative Plant component of home assistant";
    homepage = "https://github.com/Olen/homeassistant-plant";
    changelog = "https://github.com/Olen/homeassistant-plant/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
}
