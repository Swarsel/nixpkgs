{
  lib,
  aiohttp,
  aiohttp-socks,
  aiorpcx,
  buildPythonPackage,
  click,
  cryptography,
  electrum-ecc,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "electrum-aionostr";
  version = "0.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-N3T46DEjiCcuEIUahpyfTT1KVNjVZIUcNuLcQCl77IQ=";
    pname = "electrum_aionostr";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  checkInputs = [ click ];
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    aiohttp-socks
    aiorpcx
    cryptography
    electrum-ecc
  ];

  disabledTests = [
    # command line interface is broken
    "test_command_line_interface"
  ];

  pyproject = true;
  pythonImportsCheck = [ "electrum_aionostr" ];

  meta = {
    description = "Asyncio nostr client";
    homepage = "https://github.com/spesmilo/electrum-aionostr";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
