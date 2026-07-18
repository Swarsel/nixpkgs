{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  django-extensions,
  pytest-django,
  pytestCheckHook,
  # propagates
  python-dateutil,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-hierarkey";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "raphaelm";
    repo = "django-hierarkey";
    tag = version;
    hash = "sha256-zIz7aokOGLGXV/xJnYcz8lBP7b2rxLrfaD3i/DLpFR8=";
  };

  env.DJANGO_SETTINGS_MODULE = "tests.settings";

  nativeCheckInputs = [
    django-extensions
    pytest-django
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ python-dateutil ];
  enabledTestPaths = [ "tests" ];
  pyproject = true;
  pythonImportsCheck = [ "hierarkey" ];

  meta = {
    description = "Flexible and powerful hierarchical key-value store for your Django models";
    homepage = "https://github.com/raphaelm/django-hierarkey";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
