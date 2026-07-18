{
  lib,
  fetchFromGitHub,
  aiofiles,
  aiohttp,
  buildPythonPackage,
  freezegun,
  gtfs-realtime-bindings,
  hatchling,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-httpserver,
  pytestCheckHook,
  python-dotenv,
  requests,
  syrupy,
}:

buildPythonPackage (finalAttrs: {
  pname = "gtfs-station-stop";
  version = "0.11.7";

  src = fetchFromGitHub {
    owner = "bcpearce";
    repo = "gtfs-station-stop";
    tag = finalAttrs.version;
    hash = "sha256-Z9pOdLXcNGK1ng7qhzg2J7CvSoDIOczN4P5Es5F2cLs=";
  };

  nativeCheckInputs = [
    freezegun
    pytest-asyncio
    pytest-cov-stub
    pytest-httpserver
    pytestCheckHook
    python-dotenv
    syrupy
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ hatchling ];

  dependencies = [
    aiofiles
    aiohttp
    gtfs-realtime-bindings
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "gtfs_station_stop" ];

  # both are added to deps but not used
  pythonRemoveDeps = [
    "asyncio-atexit"
    "coverage-badge"
  ];

  meta = {
    description = "Python library for Reformatting GTFS data for Station Arrivals";
    homepage = "https://github.com/bcpearce/gtfs-station-stop";
    changelog = "https://github.com/bcpearce/gtfs-station-stop/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.stepbrobd ];
  };
})
