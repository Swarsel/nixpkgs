{
  lib,
  fetchFromGitHub,
  # testing
  anyio,
  # propagated
  backports-zstd,
  brotli,
  buildPythonPackage,
  django,
  hatchling,
  libvalkey,
  lz4,
  msgpack,
  msgspec,
  pytest-django,
  pytest-mock,
  pytestCheckHook,
  pythonOlder,
  redisTestHook,
  valkey,
}:

buildPythonPackage rec {
  pname = "django-valkey";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "django-commons";
    repo = "django-valkey";
    tag = version;
    hash = "sha256-kXp4i7E2DnrMi0tTg8kdWmuImIWIPKTM5s7sPLWPFko=";
  };

  nativeCheckInputs = [
    anyio
    pytest-django
    pytest-mock
    pytestCheckHook
    redisTestHook # contains valkey
  ]
  ++ lib.flatten (lib.attrValues optional-dependencies);

  __darwinAllowLocalNetworking = true;
  build-system = [ hatchling ];

  dependencies = [
    django
    valkey
  ];

  disabledTestPaths = [
    # requires valkey cluster
    "tests/tests_cluster/test_backend.py"
    "tests/tests_cluster/test_cache_options.py"
    "tests/tests_cluster/test_client.py"

    # AttributeError: 'ValkeyCache' object has no attribute 'aset'
    "tests/tests_async/test_backend.py"
    # TypeError: object NoneType can't be used in 'await' expression
    "tests/tests_async/test_cache_options.py"
    # AttributeError: 'DefaultClient' object has no attribute 'aset'. Did you mean: 'hset'?
    "tests/tests_async/test_client.py"
    # AttributeError: 'ValkeyCache' object has no attribute 'ahas_key'
    "tests/tests_async/test_session.py"

    "tests/tests_async/test_requests.py"
  ];

  optional-dependencies = {
    brotli = [ brotli ];
    libvalkey = [ libvalkey ];
    lz4 = [ lz4 ];
    msgpack = [ msgpack ];
    msgspec = [ msgspec ];
    pyzstd = lib.optionals (pythonOlder "3.14") [ backports-zstd ];
    zstd = lib.optionals (pythonOlder "3.14") [ backports-zstd ];
  };

  pyproject = true;
  pythonImportsCheck = [ "django_valkey" ];

  meta = {
    description = "Valkey backend for django";
    homepage = "https://github.com/django-commons/django-valkey";
    changelog = "https://github.com/django-commons/django-valkey/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
