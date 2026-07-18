{
  lib,
  fetchFromGitHub,
  aioresponses,
  buildHomeAssistantComponent,
  # tests
  home-assistant,
  # dependencies
  numpy,
  pytest-freezegun,
  pytest-homeassistant-custom-component,
  pytestCheckHook,
}:

buildHomeAssistantComponent rec {
  version = "1.21.2";

  src = fetchFromGitHub {
    inherit owner;
    repo = "homeassistant-powercalc";
    tag = "v${version}";
    hash = "sha256-D8gFEhitQjryZLLcP2ZsXNqWLvPyayuoYGq5C0B2D5w=";
  };

  nativeCheckInputs = [
    pytest-homeassistant-custom-component
    pytestCheckHook
    aioresponses
    pytest-freezegun
  ]
  ++ home-assistant.getPackages "camera" home-assistant.python3Packages;

  preCheck = ''
    patchShebangs --build tests/setup.sh
    tests/setup.sh
  '';

  dependencies = [ numpy ];

  disabledTests = [
    # test contacts api.powercalc.nl
    "test_exception_is_raised_on_github_resource_unavailable"
  ];

  domain = "powercalc";
  owner = "bramstroker";

  meta = {
    description = "Custom Home Assistant component for virtual power sensors";
    homepage = "https://github.com/bramstroker/homeassistant-powercalc";
    changelog = "https://github.com/bramstroker/homeassistant-powercalc/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ CodedNil ];
  };
}
