{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dj-database-url,
  django,
  djangorestframework,
  inflection,
  pydantic,
  pytest-django,
  pytestCheckHook,
  pyyaml,
  syrupy,
  typing-extensions,
  uritemplate,
  uv-build,
}:

buildPythonPackage rec {
  pname = "django-pydantic-field";
  version = "0.5.4";

  src = fetchFromGitHub {
    owner = "surenkov";
    repo = "django-pydantic-field";
    tag = "v${version}";
    hash = "sha256-pnB6kYfN67102Z3R41BHIWnWoJQgd/ixyT+bbtY9PC8=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.9.17,<0.10.0" uv_build
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-django
    djangorestframework
    dj-database-url
    inflection
    pyyaml
    syrupy
    uritemplate
  ];

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=tests.settings.django_test_settings
  '';

  build-system = [ uv-build ];

  dependencies = [
    django
    pydantic
    typing-extensions
  ];

  pyproject = true;

  meta = {
    description = "Django JSONField with Pydantic models as a Schema";
    homepage = "https://github.com/surenkov/django-pydantic-field";
    changelog = "https://github.com/surenkov/django-pydantic-field/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kiara ];
  };
}
