{
  lib,
  fetchFromGitHub,
  aio-geojson-client,
  aiohttp,
  aiointercept,
  aioresponses,
  buildPythonPackage,
  geojson,
  pytest-asyncio,
  pytestCheckHook,
  pytz,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aio-geojson-generic-client";
  version = "2026.6.0";

  src = fetchFromGitHub {
    owner = "exxamalte";
    repo = "python-aio-geojson-generic-client";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZRPagyzFAa7f6liT1hWVf6FtabxPKfOzMS/Id14Jpv0=";
  };

  nativeCheckInputs = [
    aioresponses
    aiointercept
    pytest-asyncio
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    aio-geojson-client
    geojson
    pytz
  ];

  pyproject = true;
  pythonImportsCheck = [ "aio_geojson_generic_client" ];

  meta = {
    description = "Python library for accessing GeoJSON feeds";
    homepage = "https://github.com/exxamalte/python-aio-geojson-generic-client";
    changelog = "https://github.com/exxamalte/python-aio-geojson-generic-client/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
