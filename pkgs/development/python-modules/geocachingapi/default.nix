{
  lib,
  fetchFromGitHub,
  aiohttp,
  backoff,
  buildPythonPackage,
  fetchpatch,
  reverse-geocode,
  setuptools-scm,
  yarl,
}:

buildPythonPackage rec {
  pname = "geocachingapi";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "Sholofly";
    repo = "geocachingapi-python";
    tag = version;
    hash = "sha256-zme1jqn3qtoo39zyj4dKxt9M7gypMqJu0bfgY1iYhjs=";
  };

  patches = [
    # https://github.com/Sholofly/geocachingapi-python/pull/25
    (fetchpatch {
      hash = "sha256-AtjZJ9tnBeOv76fVIiqY45MeYTzcWvXCtbc6DevH8aM=";
      name = "replace-async-timeout-with-asyncio.timeout.patch";
      url = "https://github.com/Sholofly/geocachingapi-python/commit/2ba042bc2a6ebb4a494f71821502df4534eeb1a1.patch";
    })
  ];

  # Tests require a token and network access
  doCheck = false;
  build-system = [ setuptools-scm ];

  dependencies = [
    aiohttp
    backoff
    reverse-geocode
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "geocachingapi" ];
  pythonRelaxDeps = [ "reverse_geocode" ];

  meta = {
    description = "Python API to control the Geocaching API";
    homepage = "https://github.com/Sholofly/geocachingapi-python";
    changelog = "https://github.com/Sholofly/geocachingapi-python/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
