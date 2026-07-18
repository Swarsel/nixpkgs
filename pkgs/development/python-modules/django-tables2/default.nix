{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  django,
  # tests
  django-filter,
  # build-system
  hatchling,
  lxml,
  openpyxl,
  psycopg2,
  pytest-django,
  pytestCheckHook,
  pytz,
  pyyaml,
  tablib,
}:

buildPythonPackage rec {
  pname = "django-tables2";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "jieter";
    repo = "django-tables2";
    tag = "v${version}";
    hash = "sha256-hy1eh+cSYK7TPgenCEo8J7msKgvk7i69PUb6m9NuCIA=";
  };

  env.DJANGO_SETTINGS_MODULE = "tests.app.settings";

  nativeCheckInputs = [
    django-filter
    lxml
    openpyxl
    psycopg2
    pytz
    pyyaml
    pytest-django
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ hatchling ];
  dependencies = [ django ];

  optional-dependencies = {
    tablib = [ tablib ] ++ tablib.optional-dependencies.xls ++ tablib.optional-dependencies.yaml;
  };

  pyproject = true;

  meta = {
    description = "Django app for creating HTML tables";
    homepage = "https://github.com/jieter/django-tables2";
    changelog = "https://github.com/jieter/django-tables2/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
