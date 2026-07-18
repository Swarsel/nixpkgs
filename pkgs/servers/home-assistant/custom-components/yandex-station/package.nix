{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  home-assistant,
  pytestCheckHook,
  zeroconf,
}:
buildHomeAssistantComponent rec {
  version = "3.21.4";

  src = fetchFromGitHub {
    owner = "AlexxIT";
    repo = "YandexStation";
    tag = "v${version}";
    hash = "sha256-NbR8CqF7dr0q2nFZHi90IGmDELflcboeJTlVeYoBdvw=";
  };

  nativeCheckInputs = [
    home-assistant
    pytestCheckHook
  ]
  ++ (home-assistant.getPackages "stream" home-assistant.python3Packages);

  dependencies = [
    zeroconf
  ];

  disabledTestPaths = [
    # this test seems to be broken
    "tests/test_local.py::test_track"
  ];

  disabledTests = [
    # 'µg/m³' vs 'μg/m³'
    "test_sensor_qingping"
  ];

  domain = "yandex_station";
  owner = "AlexxIT";

  meta = {
    description = "Controlling Yandex.Station and other smart home devices with Alice from Home Assistant";
    homepage = "https://github.com/AlexxIT/YandexStation";
    changelog = "https://github.com/AlexxIT/YandexStation/releases/tag/${src.tag}";
    license = lib.licenses.mit;
  };
}
