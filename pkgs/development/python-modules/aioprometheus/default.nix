{
  lib,
  fetchFromGitHub,
  aiohttp,
  aiohttp-basicauth,
  buildPythonPackage,
  fastapi,
  httpx,
  orjson,
  pytestCheckHook,
  quantile-python,
  quart,
  starlette,
  uvicorn,
}:

buildPythonPackage rec {
  pname = "aioprometheus";
  version = "unstable-2023-03-14";

  src = fetchFromGitHub {
    owner = "claws";
    repo = "aioprometheus";
    rev = "4786678b413d166c0b6e0041558d11bc1a7097b2";
    hash = "sha256-2z68rQkMjYqkszg5Noj9owWUWQGOEp/91RGiWiyZVOY=";
  };

  propagatedBuildInputs = [
    orjson
    quantile-python
  ];

  nativeCheckInputs = [
    pytestCheckHook
    aiohttp-basicauth
    httpx
    fastapi
    uvicorn
  ]
  ++ lib.concatAttrValues optional-dependencies;

  format = "setuptools";

  optional-dependencies = {
    aiohttp = [ aiohttp ];
    quart = [ quart ];
    starlette = [ starlette ];
  };

  pythonImportsCheck = [ "aioprometheus" ];

  meta = {
    description = "Prometheus Python client library for asyncio-based applications";
    homepage = "https://github.com/claws/aioprometheus";
    changelog = "https://github.com/claws/aioprometheus/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
