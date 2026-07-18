{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  pymitsubishi,
  pytest-cov-stub,
  pytest-homeassistant-custom-component,
  pytestCheckHook,
}:

buildHomeAssistantComponent rec {
  version = "0.5.7";

  src = fetchFromGitHub {
    owner = "pymitsubishi";
    repo = "homeassistant-mitsubishi";
    tag = "v${version}";
    hash = "sha256-8/zB1jbMoabd+pkIOUgY7bJ5lu2nCLkjS28Ru6bsKOw=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
    pytest-homeassistant-custom-component
  ];

  dependencies = [
    pymitsubishi
  ];

  disabledTests = [
    # tests try to open sockets
    "test_form_success"
    "test_form_already_configured"
    "test_form_with_options"
  ];

  domain = "mitsubishi";
  ignoreVersionRequirement = [ "pymitsubishi" ];
  owner = "pymitsubishi";

  meta = {
    description = "Home Assistant Mitsubishi Air Conditioner Integration";
    homepage = "https://github.com/pymitsubishi/homeassistant-mitsubishi";
    changelog = "https://github.com/pymitsubishi/homeassistant-mitsubishi/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ uvnikita ];
  };
}
