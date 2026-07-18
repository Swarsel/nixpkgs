{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  fetchpatch,
  hass-web-proxy-lib,
  pytest-aiohttp,
  pytest-cov-stub,
  pytest-freezer,
  pytest-homeassistant-custom-component,
  pytest-timeout,
  pytestCheckHook,
  urlmatch,
}:

buildHomeAssistantComponent rec {
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "dermotduffy";
    repo = "hass-web-proxy-integration";
    tag = "v${version}";
    hash = "sha256-qtiea0L0Zw0CtrUpuPjS/DuBzlV61v6K4SARzHGGgUY=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-PZBRHVoHXMiELHitmj+YmgVSQiOqEmyP4o3MBc1Yjsg=";
      # https://github.com/dermotduffy/hass-web-proxy-integration/pull/106
      url = "https://github.com/dermotduffy/hass-web-proxy-integration/commit/77964d49fd6e9d7aefe0cd9c19226a80477dc909.patch";
    })
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-aiohttp
    pytest-cov-stub
    pytest-freezer
    pytest-homeassistant-custom-component
    pytest-timeout
  ];

  dependencies = [
    hass-web-proxy-lib
    urlmatch
  ];

  domain = "hass_web_proxy";

  ignoreVersionRequirement = [
    "hass-web-proxy-lib"
  ];

  owner = "dermotduffy";

  meta = {
    description = "Home Assistant Web Proxy";
    homepage = "https://github.com/dermotduffy/hass-web-proxy-integration";
    changelog = "https://github.com/dermotduffy/hass-web-proxy-integration/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
