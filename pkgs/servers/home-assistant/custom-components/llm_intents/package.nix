{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-freezer,
  pytest-homeassistant-custom-component,
  pytestCheckHook,
  sympy,
}:

buildHomeAssistantComponent (finalAttrs: {
  version = "1.8.2";

  src = fetchFromGitHub {
    inherit (finalAttrs) owner;
    repo = "llm_intents";
    tag = finalAttrs.version;
    hash = "sha256-UYWt+PpG0M1DE1nHqLJ/npp29JyfNz19Pyb1Jv3LM48=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytest-freezer
    pytest-homeassistant-custom-component
    pytestCheckHook
  ];

  dependencies = [
    sympy
  ];

  domain = "llm_intents";
  owner = "skye-harris";

  meta = {
    description = "Exposes internet search tools for use by LLM-backed Assist in Home Assistant";
    homepage = "https://github.com/skye-harris/llm_intents";
    changelog = "https://github.com/skye-harris/llm_intents/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jpds ];
  };
})
