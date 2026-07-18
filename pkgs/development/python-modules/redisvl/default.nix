{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  jsonpath-ng,
  ml-dtypes,
  numpy,
  pydantic,
  python-ulid,
  pyyaml,
  redis,
  tenacity,
}:

buildPythonPackage (finalAttrs: {
  pname = "redisvl";
  version = "0.23.0";

  src = fetchFromGitHub {
    owner = "redis";
    repo = "redis-vl-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8BLt/9Wozvf8SIgwVJedG+T7VwWltEL8Lk922BhwmRM=";
  };

  # tests require a live Redis server with the search/vector module
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    numpy
    pyyaml
    redis
    pydantic
    tenacity
    ml-dtypes
    python-ulid
    jsonpath-ng
  ];

  pyproject = true;
  pythonImportsCheck = [ "redisvl" ];
  pythonRelaxDeps = [ "redis" ];

  meta = {
    description = "Python client library and CLI for using Redis as a vector database";
    homepage = " https://redisvl.com";
    changelog = "https://github.com/redis/redis-vl-python/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ codgician ];
    mainProgram = "rvl";
    teams = [ lib.teams.redis ];
  };
})
