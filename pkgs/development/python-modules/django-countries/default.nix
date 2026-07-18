{
  lib,
  fetchFromGitHub,
  # dependencies
  asgiref,
  buildPythonPackage,
  # tests
  django,
  djangorestframework,
  graphene-django,
  pytest-django,
  pytestCheckHook,
  typing-extensions,
  # build-system
  uv-build,
}:

buildPythonPackage rec {
  pname = "django-countries";
  version = "8.2.0";

  src = fetchFromGitHub {
    owner = "SmileyChris";
    repo = "django-countries";
    tag = "v${version}";
    hash = "sha256-MtRlZFrTlY7t0n08X0aYN5HRGZUGLHkcU1gaZCtj07Q=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.9.6,<0.10.0" uv_build
  '';

  nativeCheckInputs = [
    django
    djangorestframework
    graphene-django
    pytestCheckHook
    pytest-django
  ];

  build-system = [ uv-build ];

  dependencies = [
    asgiref
    typing-extensions
  ];

  pyproject = true;

  meta = {
    description = "Provides a country field for Django models";

    longDescription = ''
      A Django application that provides country choices for use with
      forms, flag icons static files, and a country field for models.
    '';

    homepage = "https://github.com/SmileyChris/django-countries";
    changelog = "https://github.com/SmileyChris/django-countries/blob/v${version}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
