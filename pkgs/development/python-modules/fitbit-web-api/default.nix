{
  lib,
  fetchFromGitHub,
  aiohttp,
  aiohttp-retry,
  buildPythonPackage,
  hatchling,
  pydantic,
  pytest-aiohttp,
  pytestCheckHook,
  python-dateutil,
  typing-extensions,
  urllib3,
}:

buildPythonPackage rec {
  pname = "fitbit-web-api";
  version = "2.15.0";

  src = fetchFromGitHub {
    owner = "allenporter";
    repo = "fitbit-web-api";
    tag = "v${version}";
    hash = "sha256-1XqUhQQRTlEOIbZGzRx9CvJVAE50Enu+4fQXpOgNPdA=";
  };

  nativeCheckInputs = [
    pytest-aiohttp
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    aiohttp-retry
    pydantic
    python-dateutil
    typing-extensions
    urllib3
  ];

  pyproject = true;
  pythonImportsCheck = [ "fitbit_web_api" ];

  meta = {
    description = "Access data from Fitbit activity trackers, Aria scale, and manually entered logs";
    homepage = "https://github.com/allenporter/fitbit-web-api";
    changelog = "https://github.com/allenporter/fitbit-web-api/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
