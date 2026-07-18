{
  lib,
  fetchFromGitHub,
  # dependencies
  agate,
  buildPythonPackage,
  dbt-adapters,
  dbt-common,
  dbt-core,
  google-cloud-bigquery,
  google-cloud-dataproc,
  google-cloud-storage,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "dbt-bigquery";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "dbt-labs";
    repo = "dbt-bigquery";
    tag = "v${version}";
    hash = "sha256-YZA8lcUGoq5jMNS1GlbBd036X2F3khsZWr5Pv65zpPI=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  dependencies = [
    agate
    dbt-adapters
    dbt-common
    dbt-core
    google-cloud-bigquery
    google-cloud-dataproc
    google-cloud-storage
  ];

  enabledTestPaths = [ "tests/unit" ];
  pyproject = true;
  pythonImportsCheck = [ "dbt.adapters.bigquery" ];

  pythonRelaxDeps = [
    "agate"
    "google-cloud-storage"
  ];

  meta = {
    description = "Plugin enabling dbt to operate on a BigQuery database";
    homepage = "https://github.com/dbt-labs/dbt-bigquery";
    changelog = "https://github.com/dbt-labs/dbt-bigquery/blob/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
  };
}
