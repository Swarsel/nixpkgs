{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  itsdangerous,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  redis,
  starlette,
}:

buildPythonPackage rec {
  pname = "starsessions";
  version = ".2.2.0";

  src = fetchFromGitHub {
    owner = "alex-oleshkevich";
    repo = "starsessions";
    tag = "v${version}";
    hash = "sha256-CR8eMyYyr+iFf2l1QE0N762LdkxemOayn/s++mBZRqA=";
  };

  nativeCheckInputs = [
    httpx
    pytestCheckHook
    pytest-asyncio
    pytest-cov-stub
  ];

  build-system = [ poetry-core ];

  dependencies = [
    itsdangerous
    starlette
  ];

  disabledTestPaths = [
    "tests/backends/test_redis.py" # requires a running redis instance
  ];

  optional-dependencies = {
    redis = [
      redis
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "starsessions" ];

  meta = {
    description = "Advanced sessions for Starlette and FastAPI frameworks";
    homepage = "https://github.com/alex-oleshkevich/starsessions";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ drupol ];
  };
}
