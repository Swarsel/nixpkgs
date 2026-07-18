{
  lib,
  fetchFromGitHub,
  bluetooth-data-tools,
  bluetooth-sensor-state-data,
  buildPythonPackage,
  hatchling,
  home-assistant-bluetooth,
  pytest-cov-stub,
  pytestCheckHook,
  sensor-state-data,
}:

buildPythonPackage (finalAttrs: {
  pname = "chefiq-ble";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "Invader444";
    repo = "chefiq-ble";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aC0v3KtZEnEz90kJPxx0euUM/h6NzLnvI9WggImYQ5c=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    bluetooth-data-tools
    bluetooth-sensor-state-data
    home-assistant-bluetooth
    sensor-state-data
  ];

  pyproject = true;
  pythonImportsCheck = [ "chefiq_ble" ];

  meta = {
    description = "Passive BLE advertisement parser for Chef iQ wireless probes (CQ50/CQ60)";
    homepage = "https://github.com/Invader444/chefiq-ble";
    changelog = "https://github.com/Invader444/chefiq-ble/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
