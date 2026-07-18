{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  poetry-core,
  # tests
  pytest-cov-stub,
  pytest-django,
  pytest-mock,
  pytest-randomly,
  pytestCheckHook,
  # dependencies
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "django-test-migrations";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "wemake-services";
    repo = "django-test-migrations";
    tag = finalAttrs.version;
    hash = "sha256-mYDGGfkLo+GMgItCje46KtXdPsedawRKXLbRnD+CC+8=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytest-django
    pytest-mock
    pytest-randomly
    pytestCheckHook
  ];

  preCheck = ''
    export DJANGO_DATABASE_NAME=test_db
  '';

  build-system = [
    poetry-core
  ];

  dependencies = [
    typing-extensions
  ];

  disabledTests = [
    # nested pytest calls complain about import file mismatch (out vs source)
    "test_call_pytest_setup_plan"
    "test_pytest_markers"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "django_test_migrations"
  ];

  meta = {
    description = "Test django schema and data migrations, including migrations' order and best practices";
    homepage = "https://github.com/wemake-services/django-test-migrations";
    changelog = "https://github.com/wemake-services/django-test-migrations/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
