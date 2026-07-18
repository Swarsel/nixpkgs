{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  django-js-asset,
  hatchling,
  model-bakery,
  pytest-django,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "django-mptt";
  version = "0.18";

  src = fetchFromGitHub {
    owner = "django-mptt";
    repo = "django-mptt";
    rev = version;
    hash = "sha256-UJQwjOde0DkG/Pa/pd2htnp4KEn5KwYAo8GP5A7/h+I=";
  };

  nativeCheckInputs = [
    model-bakery
    pytestCheckHook
    pytest-django
  ];

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=tests.settings
    export PYTHONPATH=$(pwd)/tests:$PYTHONPATH
  '';

  build-system = [ hatchling ];

  dependencies = [
    django
    django-js-asset
  ];

  pyproject = true;
  pythonImportsCheck = [ "mptt" ];

  meta = {
    description = "Utilities for implementing a modified pre-order traversal tree in Django";
    homepage = "https://github.com/django-mptt/django-mptt";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ hexa ];
  };
}
