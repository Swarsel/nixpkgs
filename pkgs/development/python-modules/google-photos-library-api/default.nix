{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  mashumaro,
  pytest-aiohttp,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "google-photos-library-api";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "allenporter";
    repo = "python-google-photos-library-api";
    tag = version;
    hash = "sha256-pmAAvwhr783ih9vpqr5DmT462z3Ug1xwHaz9itu/mt4=";
  };

  nativeCheckInputs = [
    pytest-aiohttp
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    mashumaro
  ];

  pyproject = true;
  pythonImportsCheck = [ "google_photos_library_api" ];

  meta = {
    description = "Python client library for Google Photos Library API";
    homepage = "https://github.com/allenporter/python-google-photos-library-api";
    changelog = "https://github.com/allenporter/python-google-photos-library-api/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
