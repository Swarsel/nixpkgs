{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  distutils,
  django,
  django-app-helper,
  django-polymorphic,
  easy-thumbnails,
  pillow-heif,
  pytestCheckHook,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-filer";
  version = "3.4.4";

  src = fetchFromGitHub {
    owner = "django-cms";
    repo = "django-filer";
    tag = version;
    hash = "sha256-HB82YDS6RV4wg10XUxGpfRzebIbI5QMvyzYq01AWWj0=";
  };

  checkInputs = [
    distutils
    django-app-helper
  ];

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} tests/settings.py
    runHook postCheck
  '';

  build-system = [ setuptools ];

  dependencies = [
    django
    django-polymorphic
    easy-thumbnails
  ]
  ++ easy-thumbnails.optional-dependencies.svg;

  optional-dependencies = {
    heif = [ pillow-heif ];
  };

  pyproject = true;

  meta = {
    description = "File management application for Django";
    homepage = "https://github.com/django-cms/django-filer";
    changelog = "https://github.com/django-cms/django-filer/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.onny ];
  };
}
