{
  lib,
  buildPythonPackage,
  django,
  fetchPypi,
  pytest-django,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-tinymce";
  version = "5.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-YldmntWWrM9fqWf/MGEnayxTUrqsG7xlj82CUrEso4o=";
    pname = "django_tinymce";
  };

  env.DJANGO_SETTINGS_MODULE = "tests.settings";

  checkInputs = [
    pytest-django
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ django ];
  pyproject = true;
  pythonImportsCheck = [ "tinymce" ];

  meta = {
    description = "Django application that contains a widget to render a form field as a TinyMCE editor";
    homepage = "https://github.com/jazzband/django-tinymce";
    changelog = "https://github.com/jazzband/django-tinymce/blob/${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.onny ];
  };
}
