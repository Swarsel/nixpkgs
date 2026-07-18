{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  pytest-django,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "django-crispy-forms";
  version = "2.6";

  src = fetchFromGitHub {
    owner = "django-crispy-forms";
    repo = "django-crispy-forms";
    tag = finalAttrs.version;
    hash = "sha256-yU5xNlV3OFZUdO6zK1sG7mHGkNXLwZocEH8JhvAwyAc=";
  };

  propagatedBuildInputs = [
    django
    setuptools
  ];

  # FIXME: RuntimeError: Model class source.crispy_forms.tests.forms.CrispyTestModel doesn't declare an explicit app_label and isn't in an application in INSTALLED_APPS.
  doCheck = false;

  nativeCheckInputs = [
    pytest-django
    pytestCheckHook
  ];

  enabledTestPaths = [
    "crispy_forms/tests/"
  ];

  pyproject = true;

  pytestFlags = [
    "--ds=crispy_forms.tests.test_settings"
  ];

  pythonImportsCheck = [ "crispy_forms" ];

  meta = {
    description = "Best way to have DRY Django forms";
    homepage = "https://django-crispy-forms.readthedocs.io/en/latest/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ambroisie ];
  };
})
