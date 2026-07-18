{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  django,
  djangorestframework,
  # tests
  pytest-cov-stub,
  pytest-django,
  pytest-mock,
  pytestCheckHook,
  # build-system
  setuptools,
  ujson,
}:

buildPythonPackage rec {
  pname = "drf-ujson2";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "Amertz08";
    repo = "drf_ujson2";
    tag = "v${version}";
    hash = "sha256-NtloZWsEmRbPl7pdxPQqpzIzTyyOEFO9KtZ60F7VuUQ=";
  };

  env.DJANGO_SETTINGS_MODULE = "tests.settings";

  nativeCheckInputs = [
    pytest-cov-stub
    pytest-django
    pytest-mock
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    django
    djangorestframework
    ujson
  ];

  pyproject = true;

  meta = {
    description = "JSON parser and renderer using ujson for Django Rest Framework";
    homepage = "https://github.com/Amertz08/drf_ujson2";
    changelog = "https://github.com/Amertz08/drf_ujson2/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
