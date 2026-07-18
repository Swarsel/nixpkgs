{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  pytest-django,
  pytestCheckHook,
  setuptools,
  six,
}:

buildPythonPackage (finalAttrs: {
  pname = "django-annoying";
  version = "0.10.8";

  src = fetchFromGitHub {
    owner = "skorokithakis";
    repo = "django-annoying";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zBOHVar4iKb+BioIwmDosNZKi/0YcjYfBusn0Lv8pMw=";
  };

  env.DJANGO_SETTINGS_MODULE = "tests.settings";

  nativeCheckInputs = [
    pytest-django
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    django
    six
  ];

  pyproject = true;

  meta = {
    description = "Django application that tries to eliminate annoying things in the Django framework";
    homepage = "https://skorokithakis.github.io/django-annoying/";
    changelog = "https://github.com/skorokithakis/django-annoying/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ambroisie ];
  };
})
