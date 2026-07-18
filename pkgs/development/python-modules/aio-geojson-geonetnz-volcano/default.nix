{
  lib,
  fetchFromGitHub,
  aio-geojson-client,
  aiohttp,
  aiointercept,
  aioresponses,
  buildPythonPackage,
  mock,
  pytest-asyncio,
  pytest-xdist,
  pytestCheckHook,
  pytz,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aio-geojson-geonetnz-volcano";
  version = "2026.6.0";

  src = fetchFromGitHub {
    owner = "exxamalte";
    repo = "python-aio-geojson-geonetnz-volcano";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BA8ejjzwonIYsLrBP3MGBfZ3bKoj2h/Qe4TcjL16FOA=";
  };

  nativeCheckInputs = [
    aiointercept
    aioresponses
    mock
    pytest-asyncio
    pytest-xdist
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    aio-geojson-client
    aiohttp
    pytz
  ];

  pyproject = true;
  pythonImportsCheck = [ "aio_geojson_geonetnz_volcano" ];

  meta = {
    description = "Python module for accessing the GeoNet NZ Volcanic GeoJSON feeds";
    homepage = "https://github.com/exxamalte/python-aio-geojson-geonetnz-volcano";
    changelog = "https://github.com/exxamalte/python-aio-geojson-geonetnz-volcano/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
