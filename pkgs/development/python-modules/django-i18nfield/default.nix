{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  djangorestframework,
  html5lib,
  lxml,
  pytest-django,
  pytestCheckHook,
  pyyaml,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-i18nfield";
  version = "1.11.0";

  src = fetchFromGitHub {
    owner = "raphaelm";
    repo = "django-i18nfield";
    tag = version;
    hash = "sha256-0r4ICS8E0OFMrR7IoyiFyXBvAkQjSBb0HtEcb31f4Rw=";
  };

  env.DJANGO_SETTINGS_MODULE = "tests.settings";

  nativeCheckInputs = [
    djangorestframework
    html5lib
    lxml
    pytest-django
    pytestCheckHook
    pyyaml
  ];

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Store internationalized strings in Django models";
    homepage = "https://github.com/raphaelm/django-i18nfield";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
