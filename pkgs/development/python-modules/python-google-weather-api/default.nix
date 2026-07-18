{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  mashumaro,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-google-weather-api";
  version = "0.0.6";

  src = fetchFromGitHub {
    owner = "tronikos";
    repo = "python-google-weather-api";
    tag = "v${version}";
    hash = "sha256-Vbiw2fbSGBIBmM8siRSTSjt64ZM7k/HFv/V66dzY6B0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    mashumaro
  ];

  pyproject = true;
  pythonImportsCheck = [ "google_weather_api" ];

  meta = {
    description = "Python client library for the Google Weather API";
    homepage = "https://github.com/tronikos/python-google-weather-api";
    changelog = "https://github.com/tronikos/python-google-weather-api/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
