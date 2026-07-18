{
  lib,
  fetchFromGitHub,
  # optional dependencies
  asgiref,
  blinker,
  buildPythonPackage,
  django,
  # tests
  django-redis,
  fakeredis,
  fastapi,
  flask,
  httpx,
  jsonschema,
  pytest-cov-stub,
  pytest-django,
  pytest-mock,
  pytestCheckHook,
  redis,
  redisTestHook,
  sanic,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "dockerflow";
  version = "2026.03.04";

  src = fetchFromGitHub {
    owner = "mozilla-services";
    repo = "python-dockerflow";
    tag = version;
    hash = "sha256-cNf9qsoIJY5aRsQ82WZPmOrq2V6Siidp2B36JFTnMVw=";
  };

  nativeCheckInputs = [
    fakeredis
    jsonschema
    pytestCheckHook
    pytest-cov-stub
    pytest-mock
    redis
    redisTestHook

    # django
    django-redis
    pytest-django

    # fastapi
    httpx
  ]
  ++ lib.concatAttrValues optional-dependencies;

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=tests.django.settings
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  disabledTestPaths = [
    # missing flask-redis dependency
    "tests/flask/test_flask.py"
    # missing sanic-redis dependency
    "tests/sanic/test_sanic.py"
  ];

  disabledTests = [
    # AssertionError: assert 'c7a05e2b-8a21-4255-a3ed-92cea1e74a62' is None
    "test_mozlog_without_correlation_id_middleware"
  ];

  optional-dependencies = {
    django = [ django ];

    fastapi = [
      asgiref
      fastapi
    ];

    flask = [
      blinker
      flask
    ];

    sanic = [ sanic ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "dockerflow"
  ];

  meta = {
    description = "Python package to implement tools and helpers for Mozilla Dockerflow";
    homepage = "https://github.com/mozilla-services/python-dockerflow";
    changelog = "https://github.com/mozilla-services/python-dockerflow/releases/tag/${src.tag}";
    license = lib.licenses.mpl20;
  };
}
