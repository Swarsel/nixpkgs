{
  lib,
  aiohttp,
  async-timeout,
  buildPythonPackage,
  fetchPypi,
  pytest-asyncio,
  pytest-httpserver,
  pytestCheckHook,
  setuptools-scm,
  voluptuous,
}:

buildPythonPackage rec {
  pname = "solax";
  version = "3.2.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-60FIDhd60zaWcwPnq7P7WxuXQc1MivWNTctj3TuZF3k=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-httpserver
    pytestCheckHook
  ];

  build-system = [ setuptools-scm ];

  dependencies = [
    aiohttp
    async-timeout
    voluptuous
  ];

  disabledTests = [
    # Tests require network access
    "test_discovery"
    "test_smoke"
  ];

  pyproject = true;
  pythonImportsCheck = [ "solax" ];

  meta = {
    description = "Python wrapper for the Solax Inverter API";
    homepage = "https://github.com/squishykid/solax";
    changelog = "https://github.com/squishykid/solax/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
