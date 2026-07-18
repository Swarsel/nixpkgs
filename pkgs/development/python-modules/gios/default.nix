{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  dacite,
  pytest-asyncio,
  pytest-error-for-skips,
  pytestCheckHook,
  pythonOlder,
  setuptools,
  syrupy,
}:

buildPythonPackage rec {
  pname = "gios";
  version = "7.1.0";

  src = fetchFromGitHub {
    owner = "bieniu";
    repo = "gios";
    tag = version;
    hash = "sha256-m7baTU7oWcjqCgiZ7GcOYVM23jcvycQcAbPhO1jWahk=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytest-error-for-skips
    pytestCheckHook
    syrupy
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    dacite
  ];

  disabled = pythonOlder "3.13";

  disabledTests = [
    # Test requires network access
    "test_invalid_station_id"
  ];

  pyproject = true;
  pythonImportsCheck = [ "gios" ];

  meta = {
    description = "Python client for getting air quality data from GIOS";
    homepage = "https://github.com/bieniu/gios";
    changelog = "https://github.com/bieniu/gios/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
