{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  django-crispy-forms,
  pytest-django,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "crispy-bootstrap3";
  version = "2024.1";

  src = fetchFromGitHub {
    owner = "django-crispy-forms";
    repo = "crispy-bootstrap3";
    tag = version;
    hash = "sha256-w5CGWf14Wa8hndpk5r4hlz6gGykvRL+1AhA5Pz5Ejtk=";
  };

  # Tests are broken on Django >= 5.1
  # https://github.com/django-crispy-forms/crispy-bootstrap3/issues/12
  doCheck = lib.versionOlder django.version "5.1";

  nativeCheckInputs = [
    pytest-django
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    django
    django-crispy-forms
  ];

  pyproject = true;
  pythonImportsCheck = [ "crispy_bootstrap3" ];

  meta = {
    description = "Bootstrap 3 template pack for django-crispy-forms";
    homepage = "https://github.com/django-crispy-forms/crispy-bootstrap3";
    changelog = "https://github.com/django-crispy-forms/crispy-bootstrap3/blob/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ erictapen ];
  };
}
