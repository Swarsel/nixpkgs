{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  inline-snapshot,
  poetry-core,
  pytest-cov-stub,
  pytest-django,
  pytestCheckHook,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "django-choices-field";
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "bellini666";
    repo = "django-choices-field";
    tag = "v${version}";
    hash = "sha256-EnJMn6tAjhylY8qsT/T/N9v/w/vD+d93U2RMxwEcc84=";
  };

  nativeCheckInputs = [
    inline-snapshot
    pytestCheckHook
    pytest-cov-stub
    pytest-django
  ];

  build-system = [ poetry-core ];

  dependencies = [
    django
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "django_choices_field" ];

  meta = {
    description = "Django field that set/get django's new TextChoices/IntegerChoices enum";
    homepage = "https://github.com/bellini666/django-choices-field";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ minijackson ];
  };
}
