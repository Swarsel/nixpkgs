{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # propagated
  django,
  lz4,
  msgpack,
  # testing
  pytest-cov-stub,
  pytest-django,
  pytest-mock,
  pytest-xdist,
  pytestCheckHook,
  pyzstd,
  redis,
  redisTestHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-redis";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "jazzband";
    repo = "django-redis";
    tag = version;
    hash = "sha256-QfiyeeDQSRp/TkOun/HAQaPbIUY9yKPoOOEhKBX9Tec=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytest-django
    pytest-mock
    pytest-xdist
    pytestCheckHook
    redisTestHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=tests.settings.sqlite
  '';

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    django
    lz4
    msgpack
    pyzstd
    redis
  ];

  disabledTests = [
    # AttributeError: <asgiref.local._CVar object at 0x7ffff57ed950> object has no attribute 'default'
    "test_delete_pattern_with_settings_default_scan_count"
  ];

  # https://github.com/jazzband/django-redis/issues/777
  dontUsePytestXdist = true;

  optional-dependencies = {
    hiredis = [ redis ] ++ redis.optional-dependencies.hiredis;
  };

  pyproject = true;

  pytestFlags = [
    "-Wignore::DeprecationWarning"
  ];

  pythonImportsCheck = [ "django_redis" ];

  meta = {
    description = "Full featured redis cache backend for Django";
    homepage = "https://github.com/jazzband/django-redis";
    changelog = "https://github.com/jazzband/django-redis/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
