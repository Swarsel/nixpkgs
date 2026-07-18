{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  distutils,
  django,
  djangorestframework,
  persisting-theory,
  pytest-django,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-dynamic-preferences";
  version = "1.17.0";

  src = fetchFromGitHub {
    owner = "agateblue";
    repo = "django-dynamic-preferences";
    tag = version;
    hash = "sha256-irnwoWqQQxPueglI86ZIOt8wZcEHneY3eyATBXOuk9Y=";
  };

  buildInputs = [ django ];
  env.DJANGO_SETTINGS = "tests.settings";

  nativeCheckInputs = [
    djangorestframework
    pytestCheckHook
    pytest-django
  ];

  build-system = [
    setuptools
    distutils
  ];

  dependencies = [ persisting-theory ];
  pyproject = true;
  pythonImportsCheck = [ "dynamic_preferences" ];

  meta = {
    description = "Dynamic global and instance settings for your django project";
    homepage = "https://github.com/agateblue/django-dynamic-preferences";
    changelog = "https://github.com/agateblue/django-dynamic-preferences/blob/${version}/HISTORY.rst";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
