{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  dataclasses-json,
  hatchling,
  marshmallow,
  pytest-asyncio,
  pytestCheckHook,
  websockets,
}:

buildPythonPackage (finalAttrs: {
  pname = "weatherflow4py";
  version = "1.5.8";

  src = fetchFromGitHub {
    owner = "jeeftor";
    repo = "weatherflow4py";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8uGdgNWjUPOtR3lLt6VhWZSH/wcATlL8l1ILPm8d5jQ=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    dataclasses-json
    marshmallow
    websockets
  ];

  disabledTests = [
    # KeyError
    "test_convert_json_to_weather_data4"
  ];

  pyproject = true;
  pythonImportsCheck = [ "weatherflow4py" ];
  pythonRelaxDeps = [ "marshmallow" ];

  meta = {
    description = "Module to interact with the WeatherFlow REST API";
    homepage = "https://github.com/jeeftor/weatherflow4py";
    changelog = "https://github.com/jeeftor/weatherflow4py/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
