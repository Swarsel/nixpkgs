{
  lib,
  fetchFromGitHub,
  aiodns,
  aiohttp,
  aresponses,
  buildPythonPackage,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-freezer,
  pytestCheckHook,
  syrupy,
  yarl,
}:

buildPythonPackage rec {
  pname = "forecast-solar";
  version = "5.0.1";

  src = fetchFromGitHub {
    owner = "home-assistant-libs";
    repo = "forecast_solar";
    tag = "v${version}";
    hash = "sha256-fvmi5kwVAScVlGpxutjH8nl0lJx/VnQEVoj9a1UY7r4=";
  };

  env.PACKAGE_VERSION = version;

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytest-cov-stub
    pytest-freezer
    pytestCheckHook
    syrupy
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiodns
    aiohttp
    yarl
  ];

  disabledTests = [
    # "Error while resolving Forecast.Solar API address"
    "test_api_key_validation"
    "test_estimated_forecast"
    "test_internal_session"
    "test_json_request"
    "test_plane_validation"
    "test_status_400"
    "test_status_401"
    "test_status_422"
    "test_status_429"
  ];

  pyproject = true;
  pythonImportsCheck = [ "forecast_solar" ];

  meta = {
    description = "Asynchronous Python client for getting forecast solar information";
    homepage = "https://github.com/home-assistant-libs/forecast_solar";
    changelog = "https://github.com/home-assistant-libs/forecast_solar/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
