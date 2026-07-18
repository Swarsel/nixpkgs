{
  lib,
  buildPythonPackage,
  django,
  django-configurations,
  fetchPypi,
  pytest,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytest-django";
  version = "4.12.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-35TsgZqDyJecj23hPZzfvnbowh05Rzz+K0DJ/Jvjx1g=";
    pname = "pytest_django";
  };

  buildInputs = [ pytest ];

  nativeCheckInputs = [
    django-configurations
    # pytest-xidst causes random errors in the form of: django.db.utils.OperationalError: no such table: app_item
    pytestCheckHook
  ];

  preCheck = ''
    # bring pytest_django_test module into PYTHONPATH
    export PYTHONPATH="$PWD:$PYTHONPATH"

    # test the lightweight sqlite flavor
    export DJANGO_SETTINGS_MODULE="pytest_django_test.settings_sqlite"
  '';

  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ django ];
  pyproject = true;

  meta = {
    description = "Pytest plugin for testing of Django applications";
    homepage = "https://pytest-django.readthedocs.org/en/latest/";
    changelog = "https://github.com/pytest-dev/pytest-django/blob/v${finalAttrs.version}/docs/changelog.rst";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
})
