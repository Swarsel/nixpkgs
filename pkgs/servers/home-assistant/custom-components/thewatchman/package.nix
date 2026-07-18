{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  prettytable,
  pytest-cov-stub,
  pytest-homeassistant-custom-component,
  pytestCheckHook,
}:

buildHomeAssistantComponent rec {
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "dummylabs";
    repo = "thewatchman";
    tag = "v${version}";
    hash = "sha256-5BXIKh8uPKuxsLbxu0fUbuCR2LYOXk1HpOvrqehg0u0=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytest-homeassistant-custom-component
    pytestCheckHook
  ];

  dependencies = [
    prettytable
  ];

  disabledTests = [
    # the test relies on NOT changing the hass config_dir and tries to write into the nix store
    "test_status_sensor_safe_mode"
    # flaky
    "test_automations_parsing"
  ];

  domain = "watchman";
  dontBuild = true;

  ignoreVersionRequirement = [
    "prettytable"
  ];

  owner = "dummylabs";

  meta = {
    description = "Keep track of missing entities and services in your config files";
    homepage = "https://github.com/dummylabs/thewatchman";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
}
