{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  django,
  # optional-dependencies
  django-taggit,
  # tests
  pytest-django,
  pytestCheckHook,
  pytz,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-modelcluster";
  version = "6.5";

  src = fetchFromGitHub {
    owner = "wagtail";
    repo = "django-modelcluster";
    tag = "v${version}";
    hash = "sha256-jIEiwWuC+sudUHsHuG975nxrlC2yKZN/QjdvMKEeL6s=";
  };

  env.DJANGO_SETTINGS_MODULE = "tests.settings";

  nativeCheckInputs = [
    pytest-django
    pytestCheckHook
  ]
  ++ optional-dependencies.taggit;

  build-system = [ setuptools ];

  dependencies = [
    django
    pytz
  ];

  optional-dependencies.taggit = [ django-taggit ];
  pyproject = true;
  pythonImportsCheck = [ "modelcluster" ];

  meta = {
    description = "Django extension to allow working with 'clusters' of models as a single unit, independently of the database";
    homepage = "https://github.com/torchbox/django-modelcluster/";
    changelog = "https://github.com/wagtail/django-modelcluster/blob/${src.tag}/CHANGELOG.txt";
    license = lib.licenses.bsd2;
  };
}
