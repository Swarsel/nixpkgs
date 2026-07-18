{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  django-ipware,
  pytest-cov-stub,
  pytest-django,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "django-axes";
  version = "8.3.1";

  src = fetchFromGitHub {
    owner = "jazzband";
    repo = "django-axes";
    tag = version;
    hash = "sha256-DcoKXNldTXNcJTauI1torupjnKNvqmTo4/BbFXBZyFA=";
  };

  env.DJANGO_SETTINGS_MODULE = "tests.settings";

  nativeCheckInputs = [
    django-ipware
    pytestCheckHook
    pytest-cov-stub
    pytest-django
  ];

  build-system = [ setuptools-scm ];
  dependencies = [ django ];
  pyproject = true;
  pythonImportsCheck = [ "axes" ];

  meta = {
    description = "Keep track of failed login attempts in Django-powered sites";
    homepage = "https://github.com/jazzband/django-axes";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sikmir ];
  };
}
