{
  lib,
  fetchFromGitHub,
  apscheduler,
  buildPythonPackage,
  # dependencies
  django,
  pytest-django,
  # tests
  pytestCheckHook,
  pytz,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "django-apscheduler";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "jcass77";
    repo = "django-apscheduler";
    rev = "v${version}";
    hash = "sha256-2YSVX4FxE1OfJkSYV9IRKd2scV4BrMA/mBzJARQCX38=";
  };

  env.DJANGO_SETTINGS_MODULE = "tests.settings";

  nativeCheckInputs = [
    pytestCheckHook
    pytest-django
    pytz
  ];

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    django
    apscheduler
  ];

  pyproject = true;

  pythonImportsCheck = [
    "django_apscheduler"
  ];

  meta = {
    description = "APScheduler for Django";
    homepage = "https://github.com/jcass77/django-apscheduler";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ happysalada ];
  };
}
