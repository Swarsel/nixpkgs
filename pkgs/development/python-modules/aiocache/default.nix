{
  lib,
  fetchFromGitHub,
  aiohttp,
  aiomcache,
  buildPythonPackage,
  marshmallow,
  memcachedTestHook,
  msgpack,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  pythonAtLeast,
  redis,
  redisTestHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aiocache";
  version = "0.12.3";

  src = fetchFromGitHub {
    owner = "aio-libs";
    repo = "aiocache";
    tag = "v${version}";
    hash = "sha256-4QYCRXMWlt9fsiWgUTc2pKzXG7AG/zGmd4HT5ggIZNM=";
  };

  nativeCheckInputs = [
    aiohttp
    marshmallow
    memcachedTestHook
    pytest-asyncio
    pytest-cov-stub
    pytest-mock
    pytestCheckHook
    redisTestHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  disabledTestPaths = [
    # Benchmark and performance tests are not relevant for Nixpkgs
    "tests/performance/"
    # Full of timing-sensitive tests
    "tests/ut/backends/test_redis.py"

    # TypeError: object MagicMock can't be used in 'await' expression
    "tests/ut/backends/test_redis.py::TestRedisBackend::test_close"

    # flaky, see https://github.com/aio-libs/aiocache/issues/587
    "tests/acceptance/test_lock.py::TestRedLock::test_locking_dogpile"
  ];

  disabledTests = [
    # Test calls apache benchmark and fails, no usable output
    "test_concurrency_error_rates"
    # susceptible to timing out / short ttl
    "test_cached_stampede"
    "test_locking_dogpile_lease_expiration"
    "test_set_ttl_handle"
    "test_set_cancel_previous_ttl_handle"
  ]
  ++ lib.optionals (pythonAtLeast "3.13") [
    # https://github.com/aio-libs/aiocache/issues/863
    "test_cache_write_doesnt_wait_for_future"
  ];

  optional-dependencies = {
    memcached = [ aiomcache ];
    msgpack = [ msgpack ];
    redis = [ redis ];
  };

  pyproject = true;

  pytestFlags = [
    "-Wignore::DeprecationWarning"
    # Tests can time out and leave redis/valkey in an unusable state for later tests
    "-x"
  ];

  pythonImportsCheck = [ "aiocache" ];

  meta = {
    description = "Asyncio cache supporting multiple backends (memory, redis, memcached, etc.)";
    homepage = "https://github.com/aio-libs/aiocache";
    changelog = "https://github.com/aio-libs/aiocache/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
}
