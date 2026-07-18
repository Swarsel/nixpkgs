{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  djangorestframework,
  flit-core,
  pytest-django,
  pytestCheckHook,
  pytz,
}:

buildPythonPackage rec {
  pname = "django-filter";
  version = "25.2";

  src = fetchFromGitHub {
    owner = "carltongibson";
    repo = "django-filter";
    tag = version;
    hash = "sha256-hufqurodhd+cKs8UHvxbn62nfcZRg2Hcv2v/inkUoVg=";
  };

  env.DJANGO_SETTINGS_MODULE = "tests.settings";

  nativeCheckInputs = [
    djangorestframework
    pytestCheckHook
    pytest-django
    pytz
  ];

  build-system = [ flit-core ];
  dependencies = [ django ];
  pyproject = true;
  pythonImportsCheck = [ "django_filters" ];

  meta = {
    description = "Reusable Django application for allowing users to filter querysets dynamically";
    homepage = "https://github.com/carltongibson/django-filter";
    changelog = "https://github.com/carltongibson/django-filter/blob/${version}/CHANGES.rst";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
