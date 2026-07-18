{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  dataclasses-json,
  poetry-core,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "simplefin4py";
  version = "0.0.18";

  src = fetchFromGitHub {
    owner = "jeeftor";
    repo = "SimpleFin4py";
    tag = "v${version}";
    hash = "sha256-S+E2zwvrXN0YDY6IxplG0D15zSoeUPMyQt2oyM3QB2Q=";
  };

  propagatedBuildInputs = [
    aiohttp
    dataclasses-json
  ];

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  disabledTests = [
    # fails in non-UTC time zones
    "test_dates"
  ];

  pyproject = true;
  pythonImportsCheck = [ "simplefin4py" ];

  meta = {
    description = "Python API for Accessing SimpleFIN";
    homepage = "https://github.com/jeeftor/SimpleFin4py";
    changelog = "https://github.com/jeeftor/simplefin4py/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
