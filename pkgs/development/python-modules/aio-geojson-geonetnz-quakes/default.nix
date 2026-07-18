{
  lib,
  fetchFromGitHub,
  aio-geojson-client,
  aiohttp,
  aiointercept,
  aioresponses,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  pytz,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aio-geojson-geonetnz-quakes";
  version = "2026.6.0";

  src = fetchFromGitHub {
    owner = "exxamalte";
    repo = "python-aio-geojson-geonetnz-quakes";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JzhKlQR7tNRCtiEVSQGWFIDxUl6o+jhR3kKYjRCMTAU=";
  };

  nativeCheckInputs = [
    aiointercept
    aioresponses
    pytest-asyncio
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
  pythonImportsCheck = [ "aio_geojson_geonetnz_quakes" ];

  meta = {
    description = "Python module for accessing the GeoNet NZ Quakes GeoJSON feeds";
    homepage = "https://github.com/exxamalte/python-aio-geojson-geonetnz-quakes";
    changelog = "https://github.com/exxamalte/python-aio-geojson-geonetnz-quakes/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
