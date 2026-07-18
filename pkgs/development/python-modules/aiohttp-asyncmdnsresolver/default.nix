{
  lib,
  fetchFromGitHub,
  aiodns,
  aiohttp,
  buildPythonPackage,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  zeroconf,
}:

buildPythonPackage rec {
  pname = "aiohttp-asyncmdnsresolver";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "aio-libs";
    repo = "aiohttp-asyncmdnsresolver";
    rev = "v${version}";
    hash = "sha256-wqeWK7IoX2o+4Cmjq9nKh3rod0Y2C5dxP0Cju9Uk6hE=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiodns
    aiohttp
    zeroconf
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiohttp_asyncmdnsresolver" ];

  meta = {
    description = "Module to resolve mDNS with aiohttp";
    homepage = "https://github.com/aio-libs/aiohttp-asyncmdnsresolver";
    changelog = "https://github.com/aio-libs/aiohttp-asyncmdnsresolver/blob/${src.rev}/CHANGES.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
