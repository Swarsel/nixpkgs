{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pydantic,
  pytestCheckHook,
  python-dateutil,
  setuptools,
  urllib3,
}:

buildPythonPackage rec {
  pname = "sensorpush-api";
  version = "2.1.3";

  src = fetchFromGitHub {
    owner = "sstallion";
    repo = "sensorpush-api";
    tag = "v${version}";
    hash = "sha256-T/qROLlzgiRN4T8lwyXoD/8EtTqQY2+D8AXNKu5MeNE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    pydantic
    python-dateutil
    urllib3
  ];

  pyproject = true;
  pythonImportsCheck = [ "sensorpush_api" ];

  meta = {
    description = "SensorPush Public API for Python";
    homepage = "https://github.com/sstallion/sensorpush-api";
    changelog = "https://github.com/sstallion/sensorpush-api/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
