{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django-guardian,
  djangorestframework,
  pytest-django,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "djangorestframework-guardian";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "rpkilby";
    repo = "django-rest-framework-guardian";
    rev = version;
    hash = "sha256-7SaKyWoLen5DAwSyrWeA4rEmjXMcPwJ7LM7WYxk+IKs=";
  };

  env.DJANGO_SETTINGS_MODULE = "tests.settings";

  nativeCheckInputs = [
    pytest-django
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    django-guardian
    djangorestframework
  ];

  pyproject = true;
  pythonImportsCheck = [ "rest_framework_guardian" ];

  meta = {
    description = "Django-guardian support for Django REST Framework";
    homepage = "https://github.com/rpkilby/django-rest-framework-guardian";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
