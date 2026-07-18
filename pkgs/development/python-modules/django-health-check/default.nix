{
  lib,
  stdenv,
  fetchFromGitHub,
  aio-pika,
  buildPythonPackage,
  celery,
  confluent-kafka,
  dnspython,
  feedparser,
  flit-core,
  flit-scm,
  httpx,
  libredirect,
  psutil,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-django,
  pytestCheckHook,
  redis,
}:

buildPythonPackage (finalAttrs: {
  pname = "django-health-check";
  version = "4.4.3";

  src = fetchFromGitHub {
    owner = "codingjoe";
    repo = "django-health-check";
    tag = finalAttrs.version;
    hash = "sha256-brC/gMqxo6BsfMA+4u9alOtIH4js4EgdExT1LL0QXxU=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytest-django
    pytestCheckHook
    psutil
    pytest-asyncio
    libredirect.hook
  ];

  preCheck = ''
    echo "nameserver 127.0.0.1" > resolv.conf
    export NIX_REDIRECTS=/etc/resolv.conf=$(realpath resolv.conf)
  '';

  build-system = [
    flit-core
    flit-scm
  ];

  dependencies = [
    dnspython
  ];

  disabledTests = [
    # require online DNS resolution
    "test_run_check__dns_working"
    "test_check_status__nonexistent_hostname"
    "test_check_status__no_answer"
  ]
  ++ lib.optionals stdenv.isDarwin [
    # sensors_temperatures is not available on darwin: https://psutil.readthedocs.io/stable/index.html#psutil.sensors_temperatures
    "TestTemperature"
    # some metrics aren't available on darwin: https://psutil.readthedocs.io/stable/index.html#psutil.virtual_memory
    "TestMemory"
    # live_server not working on darwin
    "TestHealthCheckCommand"
  ];

  optional-dependencies = {
    atlassian = [ httpx ];
    celery = [ celery ];
    kafka = [ confluent-kafka ];
    psutil = [ psutil ];
    rabbitmq = [ aio-pika ];
    redis = [ redis ];

    rss = [
      httpx
      feedparser
    ];
  };

  preInstallCheck = ''
    export PYTHONPATH=$PWD:$PYTHONPATH
    export DJANGO_SETTINGS_MODULE=tests.testapp.settings
  '';

  pyproject = true;
  pythonImportsCheck = [ "health_check" ];

  meta = {
    description = "Pluggable app that runs a full check on the deployment";
    homepage = "https://github.com/codingjoe/django-health-check";
    changelog = "https://github.com/codingjoe/django-health-check/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      onny
      dav-wolff
    ];
  };
})
