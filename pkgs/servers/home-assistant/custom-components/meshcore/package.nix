{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  cachetools,
  meshcore,
  meshcore-cli,
  paho-mqtt,
  pynacl,
  pytest-asyncio,
  pytestCheckHook,
}:

buildHomeAssistantComponent (finalAttrs: {
  version = "2.8.0";

  src = fetchFromGitHub {
    owner = "meshcore-dev";
    repo = "meshcore-ha";
    tag = "v${finalAttrs.version}";
    hash = "sha256-K1DYBcuAilcKBzQVSUQvoA9OoxUbtfISYNY8IwgUdZk=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  dependencies = [
    cachetools
    meshcore
    meshcore-cli
    paho-mqtt
    pynacl
  ];

  domain = "meshcore";

  ignoreVersionRequirement = [
    "meshcore"
  ];

  owner = "meshcore-dev";

  meta = {
    description = "Home Assistant integration for MeshCore";
    homepage = "https://github.com/meshcore-dev/meshcore-ha/";
    changelog = "https://github.com/meshcore-dev/meshcore-ha/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.haylin ];
  };
})
