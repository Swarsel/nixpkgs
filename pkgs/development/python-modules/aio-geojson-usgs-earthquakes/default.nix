{
  lib,
  fetchFromGitHub,
  aio-geojson-client,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  pytz,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aio-geojson-usgs-earthquakes";
  version = "2026.6.0";

  src = fetchFromGitHub {
    owner = "exxamalte";
    repo = "python-aio-geojson-usgs-earthquakes";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UzLnctft/D38bqClqyyJ4b5GvVXM4CFSd6TypuLo0Y4=";
  };

  nativeCheckInputs = [
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
  pythonImportsCheck = [ "aio_geojson_usgs_earthquakes" ];

  meta = {
    description = "Module for accessing the U.S. Geological Survey Earthquake Hazards Program feeds";
    homepage = "https://github.com/exxamalte/python-aio-geojson-usgs-earthquakes";
    changelog = "https://github.com/exxamalte/python-aio-geojson-usgs-earthquakes/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
