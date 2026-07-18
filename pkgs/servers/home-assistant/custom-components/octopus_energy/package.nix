{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  mock,
  nix-update-script,
  pydantic,
  pytest-homeassistant-custom-component,
  pytestCheckHook,
}:
buildHomeAssistantComponent rec {
  version = "18.3.3";

  src = fetchFromGitHub {
    inherit owner;
    repo = "HomeAssistant-OctopusEnergy";
    tag = "v${version}";
    hash = "sha256-HETG4kp76j8nKpacuQtVMeSvu70VVe1XfZXu+bGi1eU=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-homeassistant-custom-component
    mock
  ];

  dependencies = [ pydantic ];

  disabledTestPaths = [
    # Integration tests require a valid Octopus Energy API Key
    # https://github.com/BottlecapDave/HomeAssistant-OctopusEnergy/blob/develop/CONTRIBUTING.md#integration-tests
    "tests/integration"
    "tests/local_integration"

    # These unit tests change Home Assistant's default time zone to Europe/London
    # without restoring it, which fails pytest-homeassistant-custom-component's
    # teardown
    "tests/unit/utils/test_get_off_peak_cost.py::test_when_rates_available_and_bst_then_off_peak_cost_returned"
    "tests/unit/utils/test_dict_to_typed_dict.py::test_when_utc_datetime_is_present_during_bst_then_converted_to_correct_datetime"
  ];

  domain = "octopus_energy";
  owner = "BottlecapDave";

  pytestFlags = [
    "-Wignore::pytest.PytestRemovedIn9Warning"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      # Ignore pre-release versions ("beta")
      "--version-regex=^v([0-9]+\\.[0-9]+\\.[0-9])$"
    ];
  };

  meta = {
    description = "Unofficial Home Assistant integration for interacting with Octopus Energy";
    homepage = "https://github.com/BottlecapDave/HomeAssistant-OctopusEnergy";
    changelog = "https://github.com/BottlecapDave/HomeAssistant-OctopusEnergy/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.matteopacini ];
  };

}
