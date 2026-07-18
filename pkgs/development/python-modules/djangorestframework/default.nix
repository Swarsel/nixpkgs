{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # optional-dependencies
  coreapi,
  coreschema,
  # dependencies
  django,
  django-guardian,
  inflection,
  psycopg2,
  pygments,
  pytest-django,
  # tests
  pytestCheckHook,
  pythonOlder,
  pytz,
  pyyaml,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "djangorestframework";
  version = "3.17.1";

  src = fetchFromGitHub {
    owner = "encode";
    repo = "django-rest-framework";
    tag = finalAttrs.version;
    hash = "sha256-hDAtICtVFeEXRgR5Shb0IdVlLkpf/TBDWw+2cOLJTfw=";
  };

  nativeCheckInputs = [
    pytest-django
    pytestCheckHook
    pytz
  ]
  ++ finalAttrs.passthru.optional-dependencies.complete;

  build-system = [ setuptools ];

  dependencies = [
    django
  ];

  disabledTests = [
    # https://github.com/encode/django-rest-framework/issues/9422
    "test_urlpatterns"
  ];

  optional-dependencies = {
    complete = [
      coreapi
      coreschema
      django-guardian
      inflection
      psycopg2
      pygments
      pyyaml
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "rest_framework" ];

  meta = {
    description = "Web APIs for Django, made easy";
    homepage = "https://www.django-rest-framework.org/";
    changelog = "https://github.com/encode/django-rest-framework/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd2;
  };
})
