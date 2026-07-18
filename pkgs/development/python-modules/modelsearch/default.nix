{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dj-database-url,
  # dependencies
  django,
  # tests
  django-modelcluster,
  django-taggit,
  django-tasks,
  psycopg,
  pytest-django,
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "modelsearch";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "wagtail";
    repo = "django-modelsearch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UH1t/CXJ7OX250SoUZYKMIAHuCxYxOT6l79RXI/oMLs=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools>=80,<81" setuptools
  '';

  nativeCheckInputs = [
    dj-database-url
    psycopg
    django-modelcluster
    django-taggit
    pytest-django
    pytestCheckHook
  ];

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=modelsearch.test.settings
    export SEARCH_BACKEND=db
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    django
    django-tasks
  ];

  pyproject = true;
  pythonImportsCheck = [ "modelsearch" ];

  pythonRelaxDeps = [
    "django-tasks"
  ];

  meta = {
    description = "Index Django Models with Elasticsearch or OpenSearch and query them with the ORM";
    homepage = "https://github.com/wagtail/django-modelsearch";
    changelog = "https://github.com/wagtail/django-modelsearch/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
