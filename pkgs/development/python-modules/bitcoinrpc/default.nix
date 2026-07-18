{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  orjson,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "bitcoinrpc";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "bibajz";
    repo = "bitcoin-python-async-rpc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QrLAhX2OZNP6k6TZ7OkD9phQidsExbep8MxWxQpqAU8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [ setuptools ];

  dependencies = [
    orjson
    httpx
    typing-extensions
  ];

  disabledTestPaths = [ "tests/test_connection.py" ];
  pyproject = true;
  pythonImportsCheck = [ "bitcoinrpc" ];

  meta = {
    description = "Bitcoin JSON-RPC client";
    homepage = "https://github.com/bibajz/bitcoin-python-async-rpc";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
