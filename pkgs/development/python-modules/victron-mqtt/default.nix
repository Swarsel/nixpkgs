{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  paho-mqtt,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
  victron-vrm,
}:

buildPythonPackage (finalAttrs: {
  pname = "victron-mqtt";
  version = "2026.7.2";

  src = fetchFromGitHub {
    owner = "tomer-w";
    repo = "victron_mqtt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZU5qz+21rxHnpHlV0Vn+iiBDqW110hy/4+Emblj6gWo=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-mock
    pytestCheckHook
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    paho-mqtt
  ];

  disabledTests = [
    # requires local mqtt broker
    "test_connect"
    "test_create_full_raw_snapshot"
    "test_devices_and_metrics"
    "test_two_hubs_connect"
    # network access
    "test_connect_auth_failure"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "victron_mqtt"
  ];

  meta = {
    inherit (victron-vrm.meta) maintainers;
    description = "Victron Venus MQTT client library documentation";
    homepage = "https://github.com/tomer-w/victron_mqtt";
    changelog = "https://github.com/tomer-w/victron_mqtt/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
  };
})
