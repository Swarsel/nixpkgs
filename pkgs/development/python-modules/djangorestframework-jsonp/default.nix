{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  djangorestframework,
  pytest-django,
  pytestCheckHook,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "djangorestframework-jsonp";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "jpadilla";
    repo = "django-rest-framework-jsonp";
    tag = version;
    hash = "sha256-4mIO69GhtvbQBtztHVQYIDDDSZpKg0g7BFNHEupiYTs=";
  };

  # Test fail with Django >=4
  # https://github.com/jpadilla/django-rest-framework-jsonp/issues/14
  doCheck = false;

  checkInputs = [
    pytestCheckHook
    pytest-django
  ];

  checkPhase = ''
    runHook preCheck
    rm tests/test_renderers.py
    ${python.interpreter} runtests.py
    runHook postCheck
  '';

  build-system = [ setuptools ];

  dependencies = [
    django
    djangorestframework
  ];

  pyproject = true;
  pythonImportsCheck = [ "rest_framework_jsonp" ];

  meta = {
    description = "JSONP support for Django REST Framework";
    homepage = "https://jpadilla.github.io/django-rest-framework-jsonp/";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.onny ];
  };
}
