{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  pythonOlder,
  requests,
  requests-mock,
  setuptools,
}:

buildPythonPackage rec {
  pname = "swisshydrodata";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "Bouni";
    repo = "swisshydrodata";
    tag = version;
    hash = "sha256-Yy/sc/SKKftIsZLyIJabrgcgYwbBxZMXbhTaWSIKpM8=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
    requests-mock
  ];

  build-system = [ setuptools ];

  dependencies = [
    requests
    aiohttp
  ];

  disabled = pythonOlder "3.12";
  pyproject = true;
  pythonImportsCheck = [ "swisshydrodata" ];

  meta = {
    description = "Python client to get data from the Swiss federal Office for Environment FEON";
    homepage = "https://github.com/bouni/swisshydrodata";
    changelog = "https://github.com/Bouni/swisshydrodata/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
