{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  hypothesis,
  jsonpath-ng,
  lupa,
  numpy,
  pyprobables,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
  redis,
  redisTestHook,
  sortedcontainers,
  valkey,
}:

buildPythonPackage (finalAttrs: {
  pname = "fakeredis";
  version = "2.36.2";

  src = fetchFromGitHub {
    owner = "cunla";
    repo = "fakeredis-py";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vOQBezPsgcjSUigCiW7Q+VueUTtQm3Y7hhB0mTstwKM=";
  };

  nativeCheckInputs = [
    hypothesis
    pytest-asyncio
    pytest-mock
    pytestCheckHook
    redisTestHook
    valkey
  ];

  preCheck = ''
    redisTestPort=6390
  '';

  build-system = [ hatchling ];

  dependencies = [
    redis
    sortedcontainers
  ];

  disabledTestMarks = [ "slow" ];

  disabledTests = [
    # redis.exceptions.ResponseError: unknown command 'evalsha'
    "test_async_lock"
  ];

  optional-dependencies = {
    bf = [ pyprobables ];
    cf = [ pyprobables ];
    json = [ jsonpath-ng ];
    lua = [ lupa ];
    probabilistic = [ pyprobables ];
    valkey = [ valkey ];

    vectorset = [
      jsonpath-ng
      numpy
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "fakeredis" ];

  meta = {
    description = "Fake implementation of Redis API";
    homepage = "https://github.com/cunla/fakeredis-py";
    changelog = "https://github.com/cunla/fakeredis-py/releases/tag/${finalAttrs.src.tag}";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ fab ];
  };
})
