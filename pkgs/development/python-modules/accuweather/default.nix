{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  orjson,
  pytest-asyncio,
  pytest-error-for-skips,
  pytestCheckHook,
  setuptools,
  syrupy,
  yarl,
}:

buildPythonPackage rec {
  pname = "accuweather";
  version = "5.1.0";

  src = fetchFromGitHub {
    owner = "bieniu";
    repo = "accuweather";
    tag = version;
    hash = "sha256-IXsf78AN5Gl6itQBfxwMEWE0ggoUohD0RgMgsgLaXOI=";
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
    orjson
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "accuweather" ];

  meta = {
    description = "Python wrapper for getting weather data from AccuWeather servers";
    homepage = "https://github.com/bieniu/accuweather";
    changelog = "https://github.com/bieniu/accuweather/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
}
