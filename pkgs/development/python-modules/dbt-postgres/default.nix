{
  lib,
  fetchFromGitHub,
  agate,
  buildPythonPackage,
  dbt-adapters,
  dbt-common,
  dbt-core,
  hatchling,
  psycopg2,
}:

buildPythonPackage rec {
  pname = "dbt-postgres";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "dbt-labs";
    repo = "dbt-postgres";
    tag = "v${version}";
    hash = "sha256-lywWf78rluX17D5bcfehHd7X18tAdw3HZ65v440jETc=";
  };

  # tests exist for the dbt tool but not for this package specifically
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    agate
    dbt-adapters
    dbt-common
    dbt-core
    psycopg2
  ];

  pyproject = true;
  pythonImportsCheck = [ "dbt.adapters.postgres" ];
  pythonRemoveDeps = [ "psycopg2-binary" ];

  meta = {
    description = "Plugin enabling dbt to work with a Postgres database";
    homepage = "https://github.com/dbt-labs/dbt-core";
    license = lib.licenses.asl20;
  };
}
