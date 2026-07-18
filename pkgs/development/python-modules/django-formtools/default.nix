{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  pytest-django,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "django-formtools";
  version = "2.6.1";

  src = fetchFromGitHub {
    owner = "jazzband";
    repo = "django-formtools";
    tag = finalAttrs.version;
    hash = "sha256-cg6bl2KJL2aOES7vWqrR25Bd6t9vWGTZLWtbMUhkCkg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-django
  ];

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=tests.settings
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ django ];

  disabledTests = [
    # mismatch between test collection of django and pytest-django
    "TestStorage"
    # Django 6.0.6/5.2.15 compat issue
    # https://github.com/jazzband/django-formtools/issues/298
    "test_reset_cookie"
  ];

  pyproject = true;
  pythonImportsCheck = [ "formtools" ];

  meta = {
    description = "High-level abstractions for Django forms";
    homepage = "https://github.com/jazzband/django-formtools";
    changelog = "https://github.com/jazzband/django-formtools/blob/${finalAttrs.src.tag}/docs/changelog.rst";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
})
