{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  syrupy,
  yarl,
}:

buildPythonPackage rec {
  pname = "aiowithings";
  version = "3.1.6";

  src = fetchFromGitHub {
    owner = "joostlek";
    repo = "python-withings";
    tag = "v${version}";
    hash = "sha256-YC1rUyPXWbJ/xfUus5a7vw44gw7PIAdwhrUstXB/+nI=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
    syrupy
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    yarl
  ];

  disabledTests = [
    # Tests require network access
    "test_creating_own_session"
    "test_error_codes"
    "test_get_activities"
    "test_get_devices"
    "test_get_goals"
    "test_get_measurement"
    "test_get_new_device"
    "test_get_sleep_summary"
    "test_get_sleep"
    "test_get_workouts"
    "test_list_all_subscriptions"
    "test_list_subscriptions"
    "test_putting_in_own_session"
    "test_revoking"
    "test_subscribing"
    "test_timeout"
    "test_unexpected_server_response"
  ];

  pyproject = true;
  pytestFlags = [ "--snapshot-update" ];
  pythonImportsCheck = [ "aiowithings" ];

  meta = {
    description = "Module to interact with Withings";
    homepage = "https://github.com/joostlek/python-withings";
    changelog = "https://github.com/joostlek/python-withings/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
