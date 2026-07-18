{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  django,
  # tests
  pytest-django,
  pytestCheckHook,
  # build-system
  uv-build,
}:

buildPythonPackage rec {
  pname = "django-bootstrap3";
  version = "26.1";

  src = fetchFromGitHub {
    owner = "zostera";
    repo = "django-bootstrap3";
    tag = "v${version}";
    hash = "sha256-DpdgwG+4We/r3NZ50no/SurEtL1BkB3P0nMv8KRj+GY=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.9.6,<0.10.0" uv_build
  '';

  env.DJANGO_SETTINGS_MODULE = "tests.app.settings";

  nativeCheckInputs = [
    pytest-django
    pytestCheckHook
  ];

  build-system = [ uv-build ];
  dependencies = [ django ];
  pyproject = true;
  pythonImportsCheck = [ "bootstrap3" ];

  meta = {
    description = "Bootstrap 3 integration for Django";
    homepage = "https://github.com/zostera/django-bootstrap3";
    changelog = "https://github.com/zostera/django-bootstrap3/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
