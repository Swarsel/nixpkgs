{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "meteo-lt-pkg";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "Brunas";
    repo = "meteo_lt-pkg";
    tag = "v${version}";
    hash = "sha256-OjIBgIOSJ65ryIF4D/UUUa1Oq0sPkKnaQEJeviimqhE=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
  ];

  disabledTests = [
    # tests contact api.meteo.lt
    "test_get_forecast"
    "test_get_nearest_place"
  ];

  pyproject = true;
  pythonImportsCheck = [ "meteo_lt" ];

  meta = {
    description = "Meteo.Lt weather forecast package";
    homepage = "https://github.com/Brunas/meteo_lt-pkg";
    changelog = "https://github.com/Brunas/meteo_lt-pkg/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
