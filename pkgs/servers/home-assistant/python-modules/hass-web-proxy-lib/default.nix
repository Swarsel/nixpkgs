{
  lib,
  # dependencies
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  # tests
  home-assistant,
  # reverse dependencies
  home-assistant-custom-components,
  # build-system
  poetry-core,
  pytest-aiohttp,
  pytest-cov-stub,
  pytest-homeassistant-custom-component,
  pytest-timeout,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "hass-web-proxy-lib";
  version = "0.0.8";

  # no tags on git
  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-H9C8jwJeR6skvCVn8jeaWqmIL0fmcab+/BQ5SzUIt00=";
    pname = "hass_web_proxy_lib";
  };

  nativeCheckInputs = [
    home-assistant
    pytest-aiohttp
    pytest-cov-stub
    pytest-homeassistant-custom-component
    pytest-timeout
    pytestCheckHook
  ];

  build-system = [ poetry-core ];
  dependencies = [ aiohttp ];
  pyproject = true;

  pythonImportsCheck = [
    "hass_web_proxy_lib"
  ];

  passthru.tests = {
    inherit (home-assistant-custom-components) frigate;
  };

  meta = {
    description = "Library to proxy web traffic through Home Assistant integrations";
    homepage = "https://github.com/dermotduffy/hass-web-proxy-lib";
    license = lib.licenses.mit;
    maintainers = home-assistant-custom-components.frigate.meta.maintainers;
  };
})
