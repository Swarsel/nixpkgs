{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  msmart-ng,
  pytest-homeassistant-custom-component,
  pytestCheckHook,
}:

buildHomeAssistantComponent rec {
  version = "2026.7.0";

  src = fetchFromGitHub {
    owner = "mill1000";
    repo = "midea-ac-py";
    tag = version;
    hash = "sha256-lZfhZRvKdeisjQAHjYxPsyS2YL486wLtuf4ERw57vZ4=";
  };

  nativeCheckInputs = [
    pytest-homeassistant-custom-component
    pytestCheckHook
  ];

  dependencies = [ msmart-ng ];

  disabledTests = [
    # tests try to open sockets
    "test_manual_flow_ac_device"
    "test_manual_flow_cc_device"
    # lingering datacoordinator timer on test teardown
    "test_refresh_apply_race_condition"
    "test_refresh_apply_race_condition_with_proxy"
    "test_group5_entity_request_enable"
    "test_energy_sensor_request_enable"
  ];

  domain = "midea_ac";
  owner = "mill1000";

  meta = {
    description = "Home Assistant custom integration to control Midea (and associated brands) air conditioners via LAN";
    homepage = "https://github.com/mill1000/midea-ac-py";
    changelog = "https://github.com/mill1000/midea-ac-py/releases/tag/${src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      hexa
      emilylange
    ];
  };
}
