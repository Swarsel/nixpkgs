{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  gtfs-station-stop,
  pytest-cov-stub,
  pytest-freezer,
  pytest-homeassistant-custom-component,
  pytestCheckHook,
}:

buildHomeAssistantComponent rec {
  version = "0.4.8";

  src = fetchFromGitHub {
    owner = "bcpearce";
    repo = "homeassistant-gtfs-realtime";
    tag = version;
    hash = "sha256-rf11yej0IsB3Og5D4n4iAsehWODJcjC930RzcGCsIT4=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytest-freezer
    pytest-homeassistant-custom-component
    pytestCheckHook
  ];

  dependencies = [ gtfs-station-stop ];

  disabledTests = [
    # upstream snapshot is stale
    "test_diagnostics"
  ];

  domain = "gtfs_realtime";
  ignoreVersionRequirement = [ "gtfs_station_stop" ];
  owner = "bcpearce";

  meta = {
    description = "GTFS Realtime transit arrivals for Home Assistant";
    homepage = "https://github.com/bcpearce/homeassistant-gtfs-realtime";
    changelog = "https://github.com/bcpearce/homeassistant-gtfs-realtime/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.stepbrobd ];
  };
}
