{
  lib,
  buildPythonPackage,
  fetchPypi,
  google-cloud-bigquery,
  google-cloud-bigquery-storage,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "harlequin-bigquery";
  version = "1.0.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-jdDwmfiU7x4zl4hg12evrPqLEzPB2M8/1HN4d0N1EJQ=";
    pname = "harlequin_bigquery";
  };

  # To prevent circular dependency
  # as harlequin-bigquery requires harlequin which requires harlequin-bigquery
  doCheck = false;

  build-system = [
    poetry-core
  ];

  dependencies = [
    google-cloud-bigquery
    google-cloud-bigquery-storage
  ];

  pyproject = true;

  pythonRemoveDeps = [
    "harlequin"
  ];

  meta = {
    description = "Harlequin adapter for Google BigQuery";
    homepage = "https://pypi.org/project/harlequin-bigquery/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pcboy ];
  };
}
