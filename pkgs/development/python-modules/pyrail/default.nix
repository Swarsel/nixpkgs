{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  mashumaro,
  poetry-core,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pyrail";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "tjorim";
    repo = "pyrail";
    tag = "v${version}";
    hash = "sha256-MFsFtspL9cmhwu2oo8wx0Sjx2VpQe92JP9e0M7U8CL8=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    mashumaro
  ]
  ++ mashumaro.optional-dependencies.orjson;

  disabledTests = [
    # tests connect to the internet
    "test_get_composition"
    "test_get_connections"
    "test_get_disturbances"
    "test_get_liveboard"
    "test_get_stations"
    "test_get_vehicle"
    "test_liveboard_with_date_time"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyrail" ];

  meta = {
    description = "Async Python wrapper for the iRail API";
    homepage = "https://github.com/tjorim/pyrail";
    changelog = "https://github.com/tjorim/pyrail/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
