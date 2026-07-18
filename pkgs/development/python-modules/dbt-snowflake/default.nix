{
  lib,
  buildPythonPackage,
  dbt-core,
  fetchPypi,
  hatchling,
  pytestCheckHook,
  snowflake-connector-python,
}:

buildPythonPackage rec {
  pname = "dbt-snowflake";
  version = "1.11.1";

  # missing tags on GitHub
  src = fetchPypi {
    inherit version;
    hash = "sha256-C2uS13vwN9AuZ0XgrdRHMsunuzSwoM06HGFmJ45Bs0A=";
    pname = "dbt_snowflake";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];

  dependencies = [
    dbt-core
    snowflake-connector-python
  ]
  ++ snowflake-connector-python.optional-dependencies.secure-local-storage;

  enabledTestPaths = [ "tests/unit" ];
  pyproject = true;

  pytestFlags = [
    # pyproject.toml specifies -n auto which only pytest-xdist understands
    "--override-ini=addopts="
  ];

  pythonImportsCheck = [ "dbt.adapters.snowflake" ];

  pythonRelaxDeps = [
    "certifi"
  ];

  meta = {
    description = "Plugin enabling dbt to work with Snowflake";
    homepage = "https://github.com/dbt-labs/dbt-adapters/blob/main/dbt-snowflake";
    changelog = "https://github.com/dbt-labs/dbt-adapters/blob/main/dbt-snowflake/CHANGELOG.md";
    license = lib.licenses.asl20;
  };
}
