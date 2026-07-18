{
  lib,
  fetchFromGitHub,
  asgiref,
  buildPythonPackage,
  celery,
  crispy-bootstrap5,
  django,
  django-allauth,
  django-environ,
  django-extensions,
  django-ipware,
  django-ninja,
  django-redis,
  djangorestframework,
  factory-boy,
  pytest-asyncio,
  pytest-django,
  pytest-mock,
  pytestCheckHook,
  redisTestHook,
  setuptools,
  structlog,
}:
buildPythonPackage (finalAttrs: {
  pname = "django-structlog";
  version = "10.1.0";

  src = fetchFromGitHub {
    owner = "jrobichaud";
    repo = "django-structlog";
    tag = finalAttrs.version;
    hash = "sha256-HQxvkArh0WPbVoIoiiSlb2YRk+cJvow/dE/O2JjMlIQ=";
  };

  nativeCheckInputs = [
    redisTestHook
    factory-boy
    pytest-asyncio
    pytest-django
    pytest-mock
    pytestCheckHook
    django-allauth
    crispy-bootstrap5
    django-environ
    django-ninja
    django-redis
    djangorestframework
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=config.settings.test_demo_app
  '';

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    asgiref
    django
    structlog
    django-ipware
  ];

  enabledTestPaths = [ "django_structlog_demo_project" ];

  optional-dependencies = {
    celery = [ celery ];
    commands = [ django-extensions ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "django_structlog"
  ];

  meta = {
    description = "Structured Logging for Django";
    homepage = "https://github.com/jrobichaud/django-structlog";
    changelog = "https://github.com/jrobichaud/django-structlog/blob/${finalAttrs.src.tag}/docs/changelog.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kurogeek ];
  };
})
