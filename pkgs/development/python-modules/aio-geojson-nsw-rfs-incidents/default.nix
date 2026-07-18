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
  pname = "aio-geojson-nsw-rfs-incidents";
  version = "2026.6.0";

  src = fetchFromGitHub {
    owner = "exxamalte";
    repo = "python-aio-geojson-nsw-rfs-incidents";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oZLpmEqsZewPVCKo1HwKK1vzAF0Vr+Vw0bhWV5c0uCw=";
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
  pythonImportsCheck = [ "aio_geojson_nsw_rfs_incidents" ];

  meta = {
    description = "Python module for accessing the NSW Rural Fire Service incidents feeds";
    homepage = "https://github.com/exxamalte/python-aio-geojson-nsw-rfs-incidents";
    changelog = "https://github.com/exxamalte/python-aio-geojson-nsw-rfs-incidents/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
