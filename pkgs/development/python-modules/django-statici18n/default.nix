{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  django,
  django-appconf,
  # tests
  pytest-django,
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-statici18n";
  version = "2.7.1";

  src = fetchFromGitHub {
    owner = "zyegfryed";
    repo = "django-statici18n";
    tag = "v${version}";
    hash = "sha256-e6sCH/9h+Ki96hfG4ftuLo34HfZbwImThi9YxmZOmRc=";
  };

  env.DJANGO_SETTINGS_MODULE = "tests.test_project.project.settings";

  nativeCheckInputs = [
    pytest-django
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    django
    django-appconf
  ];

  pyproject = true;
  pythonImportsCheck = [ "statici18n" ];

  meta = {
    description = "Helper for generating Javascript catalog to static files";
    homepage = "https://github.com/zyegfryed/django-statici18n";
    license = lib.licenses.bsd3;

    maintainers = [
    ];
  };
}
