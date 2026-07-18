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
  pname = "crispy-bootstrap4";
  version = "2026.2";

  src = fetchFromGitHub {
    owner = "django-crispy-forms";
    repo = "crispy-bootstrap4";
    tag = version;
    hash = "sha256-mIgVM6Tc6TT6+dItxqdB/4EkwN2nSFHI/9T1fpinTOo=";
  };

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
  pythonImportsCheck = [ "crispy_bootstrap4" ];

  meta = {
    description = "Bootstrap 4 template pack for django-crispy-forms";
    homepage = "https://github.com/django-crispy-forms/crispy-bootstrap4";
    changelog = "https://github.com/django-crispy-forms/crispy-bootstrap4/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ onny ];
  };
}
