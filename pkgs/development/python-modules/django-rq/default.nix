{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  hatchling,
  prometheus-client,
  pytest-django,
  pytestCheckHook,
  pyyaml,
  redis,
  redisTestHook,
  rq,
}:

buildPythonPackage (finalAttrs: {
  pname = "django-rq";
  version = "4.1.1";

  src = fetchFromGitHub {
    owner = "rq";
    repo = "django-rq";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pp8/7pMG4CHEe+jsmZ9euAV8eEMW0Hh4ecTTHnP6DiE=";
  };

  # redis hook does not support darwin
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    pytest-django
    pytestCheckHook
    pyyaml
    redisTestHook
  ]
  ++ lib.concatAttrValues finalAttrs.finalPackage.optional-dependencies;

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=tests.settings
  '';

  build-system = [ hatchling ];

  dependencies = [
    django
    redis
    rq
  ];

  disabledTests = [
    # ValueError: Job ID must only contain letters, numbers, underscores and dashes
    "test_scheduled_jobs"
  ];

  optional-dependencies = {
    prometheus = [ prometheus-client ];
  };

  pyproject = true;

  meta = {
    description = "Simple app that provides django integration for RQ (Redis Queue)";
    homepage = "https://github.com/rq/django-rq";
    changelog = "https://github.com/rq/django-rq/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
