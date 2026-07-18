{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  json-timeseries,
  openplantbook-sdk,
  pytest-homeassistant-custom-component,
  pytestCheckHook,
}:

buildHomeAssistantComponent rec {
  version = "1.6.0";

  src = fetchFromGitHub {
    inherit owner;
    repo = "home-assistant-openplantbook";
    tag = "v${version}";
    hash = "sha256-Lk+dyrBwTqRil64fVm28bhN+q57bA5U9FpX2wFf/g8I=";
  };

  nativeCheckInputs = [
    pytest-homeassistant-custom-component
    pytestCheckHook
  ];

  dependencies = [
    json-timeseries
    openplantbook-sdk
  ];

  domain = "openplantbook";

  ignoreVersionRequirement = [
    "json-timeseries"
    "openplantbook-sdk"
  ];

  owner = "olen";

  meta = {
    description = "Integration to search and fetch data from Openplantbook.io";
    homepage = "https://github.com/Olen/home-assistant-openplantbook";
    changelog = "https://github.com/Olen/home-assistant-openplantbook/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
}
