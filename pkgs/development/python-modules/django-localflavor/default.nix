{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  django,
  # tests
  pytest-django,
  pytestCheckHook,
  python-stdnum,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-localflavor";
  version = "5.0";

  src = fetchFromGitHub {
    owner = "django";
    repo = "django-localflavor";
    tag = version;
    hash = "sha256-eYhkWfxoZlnxhCIaqBhoEt0+SbkZKkUNUAy4p3tYf4A=";
  };

  env.DJANGO_SETTINGS_MODULE = "tests.settings";

  nativeCheckInputs = [
    pytest-django
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    django
    python-stdnum
  ];

  pyproject = true;

  pythonImportsCheck = [
    # samples
    "localflavor.ar"
    "localflavor.de"
    "localflavor.fr"
    "localflavor.my"
    "localflavor.nl"
    "localflavor.us"
    "localflavor.za"
  ];

  meta = {
    description = "Country-specific Django helpers";
    homepage = "https://github.com/django/django-localflavor";
    changelog = "https://github.com/django/django-localflavor/blob/${src.tag}/docs/changelog.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
