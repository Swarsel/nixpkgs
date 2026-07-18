{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  requests,
  setuptools,
  ujson,
}:

buildPythonPackage rec {
  pname = "ayla-iot-unofficial";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "rewardone";
    repo = "ayla-iot-unofficial";
    tag = "v${version}";
    hash = "sha256-/Js2XMhGe4zPAjpeH2ON4377TAPaWPvA8+HEliYKxlw=";
  };

  # tests interact with the actual API
  doCheck = false;

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    requests
    ujson
  ];

  enabledTestPaths = [ "tests/ayla_iot_unofficial.py" ];
  pyproject = true;
  pythonImportsCheck = [ "ayla_iot_unofficial" ];

  meta = {
    description = "Unofficial python library for interacting with the Ayla IoT API";
    homepage = "https://github.com/rewardone/ayla-iot-unofficial";
    changelog = "https://github.com/rewardone/ayla-iot-unofficial/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
