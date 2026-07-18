{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  djangorestframework,
  poetry-core,
  pytest-django,
  pytest-lazy-fixtures,
  pytestCheckHook,
  pytz,
}:

buildPythonPackage rec {
  pname = "django-timezone-field";
  version = "7.2.2";

  src = fetchFromGitHub {
    owner = "mfogel";
    repo = "django-timezone-field";
    tag = version;
    hash = "sha256-EGjBzKTYXTShrPIHfBIm1LqzYGuxew7ptvlGppXOYSY=";
  };

  nativeCheckInputs = [
    djangorestframework
    pytestCheckHook
    pytest-django
    pytest-lazy-fixtures
    pytz
  ];

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=tests.settings
  '';

  build-system = [ poetry-core ];
  dependencies = [ django ];
  pyproject = true;

  pythonImportsCheck = [
    # Requested setting USE_DEPRECATED_PYTZ, but settings are not configured.
    #"timezone_field"
  ];

  meta = {
    description = "Django app providing database, form and serializer fields for pytz timezone objects";
    homepage = "https://github.com/mfogel/django-timezone-field";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
