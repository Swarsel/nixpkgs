{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  nix-update-script,
  pytest-homeassistant-custom-component,
  # Test dependencies
  pytestCheckHook,
  websockets,
}:

buildHomeAssistantComponent rec {
  version = "1.10.1";

  src = fetchFromGitHub {
    inherit owner;
    repo = "hass-dreo";
    tag = "v${version}";
    hash = "sha256-/PBTWmqx/KTKvJ5K3KeKbVeypLtiT24TOZkWO62l7wA=";
  };

  nativeCheckInputs = [
    pytest-homeassistant-custom-component
    pytestCheckHook
  ];

  dependencies = [ websockets ];
  domain = "dreo";
  owner = "JeffSteinbok";

  pytestFlags = [
    "-Wignore::pytest.PytestRemovedIn9Warning"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Dreo Smart Device Integration for Home Assistant";
    homepage = "https://github.com/JeffSteinbok/hass-dreo";
    changelog = "https://github.com/JeffSteinbok/hass-dreo/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ CodedNil ];
  };
}
