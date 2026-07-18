{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  django,
  jinja2,
  # tests
  pytest-django,
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-jinja";
  version = "2.11.0";

  src = fetchFromGitHub {
    owner = "niwinz";
    repo = "django-jinja";
    tag = version;
    hash = "sha256-0gkv9xinHux8TRiNBLl/JgcimXU3CzysxzGR2jn7OZ4=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-django
  ];

  preCheck = ''
    pushd testing
    export DJANGO_SETTINGS_MODULE=settings
  '';

  postCheck = ''
    popd
  '';

  build-system = [ setuptools ];

  dependencies = [
    django
    jinja2
  ];

  disabledTests = lib.optionals (lib.versionAtLeast django.version "5.2") [
    # https://github.com/niwinz/django-jinja/issues/317
    "test_autoscape_with_form_errors"
  ];

  enabledTestPaths = [
    "testapp/tests.py"
  ];

  pyproject = true;

  meta = {
    description = "Simple and nonobstructive jinja2 integration with Django";
    homepage = "https://github.com/niwinz/django-jinja";
    changelog = "https://github.com/niwinz/django-jinja/blob/${src.rev}/CHANGES.adoc";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
