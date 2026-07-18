{
  lib,
  buildPythonPackage,
  duckdb,
  fetchPypi,
  hatchling,
  psycopg,
  pythonAtLeast,
}:

buildPythonPackage rec {
  pname = "harlequin-postgres";
  version = "1.3.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Jdy3PpfN+xfDvP3DFGQYqY/xHOaPalH7GyUyLqydUiM=";
    pname = "harlequin_postgres";
  };

  # To prevent circular dependency
  # as harlequin-postgres requires harlequin which requires harlequin-postgres
  doCheck = false;

  build-system = [
    hatchling
  ];

  dependencies = [
    psycopg
    psycopg.pool
  ]
  ++ lib.optional (pythonAtLeast "3.14") duckdb;

  pyproject = true;

  pythonRemoveDeps = [
    "harlequin"
  ];

  meta = {
    description = "Harlequin adapter for Postgres";
    homepage = "https://pypi.org/project/harlequin-postgres/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pcboy ];
  };
}
