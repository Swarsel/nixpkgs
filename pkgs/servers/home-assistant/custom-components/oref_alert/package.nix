{
  lib,
  fetchFromGitHub,
  aiofiles,
  buildHomeAssistantComponent,
  home-assistant-frontend,
  paho-mqtt,
  pytest-cov-stub,
  pytest-freezer,
  pytest-homeassistant-custom-component,
  pytestCheckHook,
  shapely,
}:

buildHomeAssistantComponent rec {
  version = "6.20.2";

  src = fetchFromGitHub {
    owner = "amitfin";
    repo = "oref_alert";
    tag = "v${version}";
    hash = "sha256-jDrSFIFlp9BVytIVUiW3lAKAmG6N0NYS0TaUxQC26eE=";
  };

  # Do not publish cards, currently broken, attempting to write to nix store.
  postPatch = ''
    substituteInPlace custom_components/oref_alert/__init__.py \
      --replace-fail 'version = await publish_cards(hass)' 'version = "1.0.0"'
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-homeassistant-custom-component
    pytest-freezer
    pytest-cov-stub
    home-assistant-frontend
  ];

  dependencies = [
    aiofiles
    shapely
    paho-mqtt
  ];

  # These tests are broken with cards removed.
  disabledTestPaths = [
    "tests/test_custom_cards.py"
    "tests/test_init.py"
  ];

  domain = "oref_alert";
  ignoreVersionRequirement = [ "shapely" ];
  owner = "amitfin";

  meta = {
    description = "Israeli Oref Alerts";
    homepage = "https://github.com/amitfin/oref_alert";
    changelog = "https://github.com/amitfin/oref_alert/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kranzes ];
  };
}
