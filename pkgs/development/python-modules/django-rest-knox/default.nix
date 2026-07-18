{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  djangorestframework,
  freezegun,
  pytest-django,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "django-rest-knox";
  version = "5.1.0";

  src = fetchFromGitHub {
    owner = "jazzband";
    repo = "django-rest-knox";
    tag = finalAttrs.version;
    hash = "sha256-YK2dD2QAnrgDqWy506afRnEbnla4VT8RFV4Rg0BRjEY=";
  };

  nativeCheckInputs = [
    freezegun
    pytest-django
    pytestCheckHook
  ];

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=knox_project.settings
  '';

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    django
    djangorestframework
  ];

  pyproject = true;
  pythonImportsCheck = [ "knox" ];

  meta = {
    description = "Authentication module for Django REST Framework";
    homepage = "https://github.com/jazzband/django-rest-knox";
    changelog = "https://github.com/jazzband/django-rest-knox/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ darshancode2005 ];
  };
})
