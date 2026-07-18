{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  pytest-django,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "django-waffle";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "django-waffle";
    repo = "django-waffle";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wirB2Y4iONmAMVt9o8aTkeB1WQzcvktQOAMEeXMM1x8=";
  };

  patches = [
    # Middleware object requires a request -> response callable
    ./middleware-compat.patch
  ];

  nativeCheckInputs = [
    pytest-django
    pytestCheckHook
  ];

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=test_settings
  '';

  build-system = [ setuptools ];
  dependencies = [ django ];
  pyproject = true;

  meta = {
    description = "Feature flipper for Django";
    homepage = "https://waffle.readthedocs.io/en/stable/";
    changelog = "https://github.com/django-waffle/django-waffle/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.ma27 ];
  };
})
