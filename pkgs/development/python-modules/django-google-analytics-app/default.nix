{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  celery,
  django,
  importlib-metadata,
  python,
  requests,
  setuptools,
  structlog,
}:

buildPythonPackage rec {
  pname = "django-google-analytics-app";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "praekeltfoundation";
    repo = "django-google-analytics";
    tag = version;
    hash = "sha256-0KLfGZY8qq5JGb+LJXpQRS76+qXtrf/hv6QLenm+BhQ=";
  };

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} -m django check --settings=test_settings
    runHook postCheck
  '';

  build-system = [ setuptools ];

  dependencies = [
    beautifulsoup4
    celery
    django
    importlib-metadata
    requests
    structlog
  ];

  pyproject = true;
  pythonImportsCheck = [ "google_analytics" ];

  pythonRelaxDeps = [
    "celery"
    "django"
  ];

  meta = {
    description = "Django Google Analytics brings the power of server side/non-js Google Analytics to your Django projects";
    homepage = "https://github.com/praekeltfoundation/django-google-analytics/";
    changelog = "https://github.com/praekeltfoundation/django-google-analytics/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ derdennisop ];
  };
}
