{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  jsonpath-ng,
  nix-update-script,
  paho-mqtt,
  protobuf,
}:

buildHomeAssistantComponent rec {
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "tolwi";
    repo = "hassio-ecoflow-cloud";
    tag = "v${version}";
    hash = "sha256-vN+po7S+/QxAHnVHJ0EpQGoxXBmcKNMRTCOPdeZ0f90=";
  };

  dependencies = [
    jsonpath-ng
    paho-mqtt
    protobuf
  ];

  domain = "ecoflow_cloud";

  ignoreVersionRequirement = [
    "protobuf"
  ];

  owner = "tolwi";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Home Assistant component for EcoFlow Cloud";
    homepage = "https://github.com/tolwi/hassio-ecoflow-cloud";
    changelog = "https://github.com/tolwi/hassio-ecoflow-cloud/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ananthb ];
  };
}
