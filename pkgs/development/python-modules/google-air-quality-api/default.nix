{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  mashumaro,
  poetry-core,
  poetry-dynamic-versioning,
  pytest-aiohttp,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  syrupy,
  time-machine,
}:

buildPythonPackage (finalAttrs: {
  pname = "google-air-quality-api";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "Thomas55555";
    repo = "python-google-air-quality-api";
    tag = finalAttrs.version;
    hash = "sha256-hgdK7Rrw/iELRE+vSuwsRUzLDT8qE2Dhxqd4bAgxays=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'version = "0.0.0"' 'version = "${finalAttrs.version}"'
  '';

  nativeCheckInputs = [
    aioresponses
    pytest-aiohttp
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
    syrupy
    time-machine
  ];

  build-system = [
    poetry-core
    poetry-dynamic-versioning
  ];

  dependencies = [
    aiohttp
    mashumaro
  ];

  pyproject = true;
  pythonImportsCheck = [ "google_air_quality_api" ];

  meta = {
    description = "Python client library for the Google Air Quality API";
    homepage = "https://github.com/Thomas55555/python-google-air-quality-api";
    changelog = "https://github.com/Thomas55555/python-google-air-quality-api/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
