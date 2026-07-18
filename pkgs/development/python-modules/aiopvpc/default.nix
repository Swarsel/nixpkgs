{
  lib,
  fetchFromGitHub,
  aiohttp,
  async-timeout,
  buildPythonPackage,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-timeout,
  pytestCheckHook,
  python-dotenv,
}:

buildPythonPackage rec {
  pname = "aiopvpc";
  version = "4.3.1";

  src = fetchFromGitHub {
    owner = "azogue";
    repo = "aiopvpc";
    tag = "v${version}";
    hash = "sha256-1xeXfhoXRfJ7vrpRPeYmwcAGjL09iNCOm/f4pPvuZLU=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-timeout
    pytest-cov-stub
    pytestCheckHook
    python-dotenv
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    async-timeout
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiopvpc" ];

  meta = {
    description = "Python module to download Spanish electricity hourly prices (PVPC)";
    homepage = "https://github.com/azogue/aiopvpc";
    changelog = "https://github.com/azogue/aiopvpc/blob/v${version}/CHANGELOG.md";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
