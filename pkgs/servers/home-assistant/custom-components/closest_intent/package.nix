{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  pytest-asyncio,
  # Test dependencies
  pytestCheckHook,
  pyyaml,
  rapidfuzz,
}:

buildHomeAssistantComponent (finalAttrs: {
  version = "0.2.1";

  src = fetchFromGitHub {
    inherit (finalAttrs) owner;
    repo = "hass-closest-intent";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rfmQso2UJsyyCA5F+0B/7gszxy6+RUpTJtil0CxdtyY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pyyaml
  ];

  dependencies = [
    rapidfuzz
  ];

  domain = "closest_intent";
  owner = "charludo";

  meta = {
    description = "Fuzzy intent matcher for Home Assistant; garbled STT output in, actual intent out";
    homepage = "https://github.com/charludo/hass-closest-intent";
    changelog = "https://github.com/charludo/hass-closest-intent/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      charludo
      jpds
    ];
  };
})
