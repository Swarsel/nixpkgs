{
  lib,
  fetchFromGitHub,
  aiohttp,
  aiointercept,
  aioresponses,
  buildPythonPackage,
  geojson,
  haversine,
  mock,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aio-geojson-client";
  version = "2026.6.0";

  src = fetchFromGitHub {
    owner = "exxamalte";
    repo = "python-aio-geojson-client";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gC6z3If8OJKDXqpBsWFMy5rYpeqZ2wjljw/dksD0XIU=";
  };

  nativeCheckInputs = [
    aioresponses
    aiointercept
    mock
    pytest-asyncio
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    geojson
    haversine
  ];

  pyproject = true;
  pythonImportsCheck = [ "aio_geojson_client" ];
  pythonRelaxDeps = [ "geojson" ];

  meta = {
    description = "Python module for accessing GeoJSON feeds";
    homepage = "https://github.com/exxamalte/python-aio-geojson-client";
    changelog = "https://github.com/exxamalte/python-aio-geojson-client/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
