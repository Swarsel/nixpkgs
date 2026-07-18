{
  lib,
  fetchFromGitHub,
  appdirs,
  asgiref,
  attrs,
  black,
  buildPythonPackage,
  click,
  django,
  djangorestframework,
  entrypoints,
  flake8,
  mccabe,
  mypy,
  mypy-extensions,
  pycodestyle,
  pyflakes,
  pytest-django,
  # tests
  pytestCheckHook,
  pytz,
  setuptools,
  sqlparse,
  toml,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "drf-flex-fields";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "rsinger86";
    repo = "drf-flex-fields";
    tag = version;
    hash = "sha256-+9ToxCEIDpsA+BK8Uk0VueVjoId41/S93+a716EGvCU=";
  };

  patches = [
    ./django4-compat.patch
    ./drf-3.17-compat.patch
  ];

  nativeCheckInputs = [
    django
    djangorestframework
    pytestCheckHook
    pytest-django
  ];

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=tests.settings
  '';

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Dynamically set fields and expand nested resources in Django REST Framework serializers";
    homepage = "https://github.com/rsinger86/drf-flex-fields";
    changelog = "https://github.com/rsinger86/drf-flex-fields/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
