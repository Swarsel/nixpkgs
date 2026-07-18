{
  lib,
  fetchFromGitHub,
  aiohomematic,
  aiohomematic-config,
  aiohomematic-test-support,
  async-upnp-client,
  buildHomeAssistantComponent,
  home-assistant,
  openccu-data,
  openccu-loom-client,
  pytest-homeassistant-custom-component,
  pytest-xdist,
  pytestCheckHook,
}:

buildHomeAssistantComponent rec {
  version = "2.8.3";

  src = fetchFromGitHub {
    owner = "SukramJ";
    repo = "custom_homematic";
    tag = version;
    hash = "sha256-CCs4+xHQGU4x7V9OpTvAjBP0/w+sXCoxqL0BaKVt15Y=";
  };

  postPatch = ''
    min_ha_version="$(sed -nr 's/^HMIP_LOCAL_MIN_HA_VERSION.*= "([0-9.]+)"$/\1/p' custom_components/homematicip_local/const.py)"
    test \
      "$(printf '%s\n' "$min_ha_version" "${home-assistant.version}" | sort -V | head -n1)" = "$min_ha_version" \
      || (echo "error: only Home Assistant >= $min_ha_version is supported" && exit 1)
  '';

  nativeCheckInputs = [
    aiohomematic-test-support
    async-upnp-client
    pytest-homeassistant-custom-component
    pytest-xdist
    pytestCheckHook
  ];

  dependencies = [
    aiohomematic
    aiohomematic-config
    openccu-data
    openccu-loom-client
  ];

  disabledTestPaths = [
    # tries to write to the Nix store
    "tests/test_blueprints.py"
  ];

  disabledTests = [
    # custom_components.homematicip_local.support.InvalidConfig: C
    "test_async_validate_config_and_get_system_information"
  ];

  domain = "homematicip_local";
  owner = "SukramJ";

  meta = {
    description = "Custom Home Assistant Component for HomeMatic";
    homepage = "https://github.com/SukramJ/custom_homematic";
    changelog = "https://github.com/SukramJ/custom_homematic/blob/${src.tag}/changelog.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
