{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dj-database-url,
  django,
  django-test-migrations,
  hatchling,
  pytest-cov-stub,
  pytest-django,
  pytest-playwright,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "django-polymorphic";
  version = "4.5.2";

  src = fetchFromGitHub {
    owner = "django-polymorphic";
    repo = "django-polymorphic";
    tag = "v${version}";
    hash = "sha256-8MZrQErWWd4GiNaIEnGvj4jONGFzsi3bu5NervF4AnE=";
  };

  nativeCheckInputs = [
    dj-database-url
    django-test-migrations
    pytest-cov-stub
    pytest-django
    pytest-playwright
    pytestCheckHook
  ];

  build-system = [ hatchling ];
  dependencies = [ django ];

  disabledTestPaths = [
    # RuntimeError: Playwright failed to start. This often happens if browser drivers are missing.
    "src/polymorphic/tests/test_admin.py"
    "src/polymorphic/tests/examples/views/test.py::ViewExampleTests::test_view_example"
  ];

  pyproject = true;
  pythonImportsCheck = [ "polymorphic" ];

  meta = {
    description = "Improved Django model inheritance with automatic downcasting";
    homepage = "https://github.com/django-polymorphic/django-polymorphic";
    changelog = "https://github.com/jazzband/django-polymorphic/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
