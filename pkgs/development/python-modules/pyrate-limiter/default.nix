{
  lib,
  fetchFromGitHub,
  # test
  aiohttp,
  buildPythonPackage,
  # optional dependencies
  filelock,
  # build-system
  hatchling,
  psycopg,
  psycopg-pool,
  pytest-asyncio,
  pytest-xdist,
  pytestCheckHook,
  redis,
  redisTestHook,
  uv-dynamic-versioning,
}:

buildPythonPackage rec {
  pname = "pyrate-limiter";
  version = "4.4.0";

  src = fetchFromGitHub {
    owner = "vutran1710";
    repo = "PyrateLimiter";
    tag = "v${version}";
    hash = "sha256-DT4WyGrayI12Sid6yLOit68vW/YT4cHsRYjd4oo0/J8=";
  };

  nativeCheckInputs = [
    aiohttp
    filelock
    pytestCheckHook
    pytest-asyncio
    pytest-xdist
    redis
    redisTestHook
  ];

  # For redisTestHook
  __darwinAllowLocalNetworking = true;

  build-system = [
    hatchling
    uv-dynamic-versioning
  ];

  disabledTestPaths = [
    # Slow: > 1.5 seconds/test run standalone on a fast machine
    # (Apple M3 Max with highest performance settings and 36GB RAM)
    # and/or hang under load
    # https://github.com/vutran1710/PyrateLimiter/issues/245
    # https://github.com/vutran1710/PyrateLimiter/issues/247
    "tests/test_bucket_all.py"
    "tests/test_bucket_factory.py"
    "tests/test_limiter.py"
    "tests/test_multiprocessing.py"
    "tests/test_postgres_concurrent.py"
    "tests/test_multi_bucket.py"
  ];

  optional-dependencies = {
    all = [
      filelock
      redis
      psycopg
      psycopg-pool
    ];
  };

  pyproject = true;

  # Show each test name and track the slowest
  # This helps with identifying bottlenecks in the test suite
  # that are causing the build to time out on Hydra.
  pytestFlags = [
    "--durations=10"
    "-vv"
  ];

  pythonImportsCheck = [ "pyrate_limiter" ];

  meta = {
    description = "Python Rate-Limiter using Leaky-Bucket Algorimth Family";
    homepage = "https://github.com/vutran1710/PyrateLimiter";
    changelog = "https://github.com/vutran1710/PyrateLimiter/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
