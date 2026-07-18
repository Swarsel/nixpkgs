{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  home-assistant,
  # dependency
  moonraker-api,
  pytest-cov-stub,
  pytest-homeassistant-custom-component,
  pytestCheckHook,
}:

buildHomeAssistantComponent rec {
  version = "1.13.4";

  src = fetchFromGitHub {
    owner = "marcolivierarsenault";
    repo = "moonraker-home-assistant";
    tag = version;
    hash = "sha256-i6ZOcCa5LD0aw6oOvVSjT6ZMfFMweS7hBBVhV4P4tv4=";
  };

  nativeCheckInputs = [
    pytest-homeassistant-custom-component
    pytest-cov-stub
    pytestCheckHook
  ]
  ++ home-assistant.getPackages "camera" home-assistant.python3Packages;

  dependencies = [
    moonraker-api
  ];

  disabledTests = [
    # tests try to open sockets
    "test_thumbnail_camera_from_img_to_none"
    "test_bad_connection_config_flow"
  ];

  domain = "moonraker";
  #skip phases with nothing to do
  dontConfigure = true;
  owner = "marcolivierarsenault";

  meta = {
    description = "Custom integration for Moonraker and Klipper in Home Assistant";
    homepage = "https://github.com/marcolivierarsenault/moonraker-home-assistant";
    changelog = "https://github.com/marcolivierarsenault/moonraker-home-assistant/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ _9R ];
  };
}
