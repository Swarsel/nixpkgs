{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  demoji,
  openai,
}:

buildHomeAssistantComponent (finalAttrs: {
  version = "1.8.1";

  src = fetchFromGitHub {
    inherit (finalAttrs) owner;
    repo = "hass_local_openai_llm";
    tag = finalAttrs.version;
    hash = "sha256-42hfVQGFHWn+QBIdK9vVPM6nV+vaO8w8mo4FCsQur4I=";
  };

  dependencies = [
    openai
    demoji
  ];

  domain = "local_openai";
  owner = "skye-harris";

  meta = {
    description = "Home Assistant LLM integration for local OpenAI-compatible services (llama.cpp, vLLM, etc.)";
    homepage = "https://github.com/skye-harris/hass_local_openai_llm";
    changelog = "https://github.com/skye-harris/hass_local_openai_llm/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jpds ];
  };
})
