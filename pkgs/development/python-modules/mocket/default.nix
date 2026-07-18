{
  lib,
  stdenv,
  # tests
  aiohttp,
  asgiref,
  buildPythonPackage,
  # dependencies
  decorator,
  fastapi,
  fetchPypi,
  gevent,
  h11,
  # build-system
  hatchling,
  httpx,
  pook,
  psutil,
  puremagic,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  redis,
  redisTestHook,
  requests,
  sure,
  typing-extensions,
  urllib3,
  # optional-dependencies
  xxhash,
}:

buildPythonPackage rec {
  pname = "mocket";
  version = "3.14.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-n8SQbK45B+mijEbnc/Otq+8NX0CIxuOQ72FEAhnOCac=";
  };

  # Skip http tests, they require network access
  env.SKIP_TRUE_HTTP = true;

  nativeCheckInputs = [
    aiohttp
    asgiref
    fastapi
    gevent
    httpx
    psutil
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
    redis
    redisTestHook
    requests
    sure
  ]
  ++ lib.concatAttrValues optional-dependencies;

  __darwinAllowLocalNetworking = true;
  build-system = [ hatchling ];

  dependencies = [
    decorator
    h11
    puremagic
    typing-extensions
    urllib3
  ];

  disabledTests = [
    # tests that require network access (like DNS lookups)
    "test_truesendall_with_dump_from_recording"
    "test_aiohttp"
    "test_asyncio_record_replay"
    "test_gethostbyname"
    # httpx read failure
    "test_no_dangling_fds"
    # redis-py response mismatch
    "test_hgetall"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # fails on darwin due to upstream bug: https://github.com/mindflayer/python-mocket/issues/287
    "test_httprettish_httpx_session"
  ];

  optional-dependencies = {
    pook = [ pook ];
    speedups = [ xxhash ];
  };

  pyproject = true;
  pythonImportsCheck = [ "mocket" ];

  meta = {
    description = "Socket mock framework for all kinds of sockets including web-clients";
    homepage = "https://github.com/mindflayer/python-mocket";
    changelog = "https://github.com/mindflayer/python-mocket/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
