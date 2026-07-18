{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # databricks-sql-connector
  databricks-sql-connector,
  # duckdb
  duckdb,
  # tests
  findspark,
  # optional-dependencies
  # bigquery
  google-cloud-bigquery,
  google-cloud-bigquery-storage,
  # dependencies
  more-itertools,
  # openai
  openai,
  pandas,
  prettytable,
  # postgres
  psycopg2,
  # spark
  pyspark,
  pytest-forked,
  pytest-postgresql,
  pytest-xdist,
  pytestCheckHook,
  # build-system
  setuptools-scm,
  sqlglot,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "sqlframe";
  version = "3.46.2";

  src = fetchFromGitHub {
    owner = "eakmanrq";
    repo = "sqlframe";
    tag = "v${version}";
    hash = "sha256-WTeJXiIkyj9FgO1w3P6JsCTtpGzezWnsiz/boB9PdIU=";
  };

  nativeCheckInputs = [
    findspark
    pytest-forked
    pytest-postgresql
    pytest-xdist
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ setuptools-scm ];

  dependencies = [
    more-itertools
    prettytable
    sqlglot
    typing-extensions
  ];

  disabledTestPaths = [
    # duckdb.duckdb.CatalogException: Catalog Error: Table Function with name "dsdgen" is not in the catalog, but it exists in the tpcds extension.
    # "tests/integration/test_int_dataframe.py"
    "tests/integration/"
    # AttributeError: module 'pyspark.sql.functions' has no attribute 'JVMView'
    "tests/unit/*/test_activate.py"
  ];

  disabledTests = [
    # Requires google-cloud credentials
    # google.auth.exceptions.DefaultCredentialsErro
    "test_activate_bigquery_default_dataset"
    # AttributeError: module 'sqlglot.expressions' has no attribute 'Acos'
    "test_unquoted_identifiers"
  ];

  optional-dependencies = {
    bigquery = [
      google-cloud-bigquery
      google-cloud-bigquery-storage
    ]
    ++ google-cloud-bigquery.optional-dependencies.pandas;

    databricks = [ databricks-sql-connector ];

    duckdb = [
      duckdb
      pandas
    ];

    openai = [ openai ];
    pandas = [ pandas ];
    postgres = [ psycopg2 ];
    spark = [ pyspark ];
  };

  pyproject = true;
  pythonImportsCheck = [ "sqlframe" ];

  meta = {
    description = "Turning PySpark Into a Universal DataFrame API";
    homepage = "https://github.com/eakmanrq/sqlframe";
    changelog = "https://github.com/eakmanrq/sqlframe/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
