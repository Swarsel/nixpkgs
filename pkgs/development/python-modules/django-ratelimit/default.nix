{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  django-redis,
  pymemcache,
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-ratelimit";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "jsocol";
    repo = "django-ratelimit";
    tag = "v${version}";
    hash = "sha256-ZMtZSKOIIRSqH6eyC7bBeua7YLKyWW6NOXN/MDv9fy4=";
  };

  nativeBuildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    django
    django-redis
    pymemcache
  ];

  checkPhase = ''
    runHook preCheck

    export DJANGO_SETTINGS_MODULE=test_settings
    python -m django test django_ratelimit

    runHook postCheck
  '';

  pyproject = true;

  pythonImportsCheck = [
    "django_ratelimit"
  ];

  meta = {
    description = "Cache-based rate-limiting for Django";
    homepage = "https://github.com/jsocol/django-ratelimit";
    changelog = "https://github.com/jsocol/django-ratelimit/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ derdennisop ];
  };
}
