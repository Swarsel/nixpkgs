{
  lib,
  aiobtclientrpc,
  async-timeout,
  buildPythonPackage,
  fetchFromCodeberg,
  httpx,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
  setuptools,
  torf,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiobtclientapi";
  version = "1.1.4";

  src = fetchFromCodeberg {
    owner = "plotski";
    repo = "aiobtclientapi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ga3EyKhfdEKkjFktUlgLSX54QbTc/a48vmWjmRqa+4w=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-mock
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    aiobtclientrpc
    async-timeout
    httpx
    torf
  ];

  disabledTestPaths = [
    # AttributeError
    "tests/clients_test/rtorrent_test/rtorrent_api_test.py"
  ];

  disabledTests = [
    # Timing-sensitive, e.g. "AssertionError: assert 9 <= 7"
    "test_Monitor_block_until_timeout"
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiobtclientapi" ];

  pythonRelaxDeps = [
    "async-timeout"
  ];

  meta = {
    description = "Asynchronous high-level communication with BitTorrent clients";
    homepage = "https://aiobtclientapi.readthedocs.io";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ambroisie ];
  };
})
