{
  lib,
  fetchFromGitHub,
  # dependencies
  asgiref,
  buildPythonPackage,
  django,
  django-choices-field,
  # optional-dependencies
  django-debug-toolbar,
  django-guardian,
  django-model-utils,
  django-mptt,
  django-polymorphic,
  django-tree-queries,
  factory-boy,
  # build-system
  hatchling,
  pillow,
  psycopg2,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-django,
  pytest-mock,
  pytest-snapshot,
  # check inputs
  pytestCheckHook,
  strawberry-graphql,
}:

buildPythonPackage rec {
  pname = "strawberry-django";
  version = "0.86.0";

  src = fetchFromGitHub {
    owner = "strawberry-graphql";
    repo = "strawberry-django";
    tag = version;
    hash = "sha256-pWhYJsfUxfK8FH9jSPWhd2P89AVYM5Z3wA2OlU6XLRo=";
  };

  postPatch = ''
    # django.core.exceptions.ImproperlyConfigured: You're using the staticfiles app without having set the required STATIC_URL setting.
    echo 'STATIC_URL = "static/"' >> tests/django_settings.py
  '';

  nativeCheckInputs = [
    pytestCheckHook

    django-guardian
    django-model-utils
    django-mptt
    django-polymorphic
    django-tree-queries
    factory-boy
    pillow
    psycopg2
    pytest-asyncio
    pytest-cov-stub
    pytest-django
    pytest-mock
    pytest-snapshot
  ]
  ++ optional-dependencies.debug-toolbar
  ++ optional-dependencies.enum;

  build-system = [
    hatchling
  ];

  dependencies = [
    django
    asgiref
    strawberry-graphql
  ];

  optional-dependencies = {
    debug-toolbar = [ django-debug-toolbar ];
    enum = [ django-choices-field ];
  };

  pyproject = true;
  pythonImportsCheck = [ "strawberry_django" ];

  meta = {
    description = "Strawberry GraphQL Django extension";
    homepage = "https://github.com/strawberry-graphql/strawberry-django";
    changelog = "https://github.com/strawberry-graphql/strawberry-django/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ minijackson ];
  };
}
