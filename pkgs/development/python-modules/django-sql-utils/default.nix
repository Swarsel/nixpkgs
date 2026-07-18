{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  hatchling,
  pytest-django,
  pytestCheckHook,
  sqlparse,
}:

buildPythonPackage rec {
  pname = "django-sql-utils";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "martsberger";
    repo = "django-sql-utils";
    tag = version;
    hash = "sha256-OjKPxoWYheu8UQ14KvyiQyHISAQjJep+N4HRc4Msa1w=";
  };

  postPatch = ''
    echo -e "\n[tool.hatch.build.targets.wheel]\npackages = [ \"sql_util\" ]" >> pyproject.toml
  '';

  env = {
    DJANGO_SETTINGS_MODULE = "sql_util.tests.test_sqlite_settings";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-django
  ];

  build-system = [ hatchling ];

  dependencies = [
    django
    sqlparse
  ];

  pyproject = true;
  pythonImportsCheck = [ "sql_util" ];

  meta = {
    description = "SQL utilities for Django";
    homepage = "https://github.com/martsberger/django-sql-utils";
    changelog = "https://github.com/martsberger/django-sql-utils/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ defelo ];
  };
}
