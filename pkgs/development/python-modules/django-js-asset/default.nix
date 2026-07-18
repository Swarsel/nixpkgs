{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  hatchling,
  pytest-django,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "django-js-asset";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "matthiask";
    repo = "django-js-asset";
    tag = version;
    hash = "sha256-TmoT+WuOw92wWW82CpKLy0Lr+oSKf+c2diG8Gs5rWg4=";
  };

  nativeCheckInputs = [
    pytest-django
    pytestCheckHook
  ];

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=tests.testapp.settings
  '';

  build-system = [ hatchling ];
  dependencies = [ django ];
  pyproject = true;
  pythonImportsCheck = [ "js_asset" ];

  meta = {
    description = "Script tag with additional attributes for django.forms.Media";
    homepage = "https://github.com/matthiask/django-js-asset";
    changelog = "https://github.com/matthiask/django-js-asset/blob/${version}/CHANGELOG.rst";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ hexa ];
  };
}
