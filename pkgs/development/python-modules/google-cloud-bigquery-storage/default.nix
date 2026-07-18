{
  lib,
  buildPythonPackage,
  fastavro,
  fetchPypi,
  google-api-core,
  google-auth,
  google-cloud-bigquery,
  pandas,
  protobuf,
  pyarrow,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "google-cloud-bigquery-storage";
  version = "2.36.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-08HOnS06TXEWJZiJ3L48fHBQb3H2zmu+VKoKaLu6j48=";
    pname = "google_cloud_bigquery_storage";
  };

  # Dependency loop with google-cloud-bigquery
  doCheck = false;

  nativeCheckInputs = [
    google-auth
    google-cloud-bigquery
    pytestCheckHook
  ];

  preCheck = ''
    rm -r google
  '';

  build-system = [ setuptools ];

  dependencies = [
    google-api-core
    protobuf
  ]
  ++ google-api-core.optional-dependencies.grpc;

  optional-dependencies = {
    fastavro = [ fastavro ];
    pandas = [ pandas ];
    pyarrow = [ pyarrow ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "google.cloud.bigquery_storage"
    "google.cloud.bigquery_storage_v1"
    "google.cloud.bigquery_storage_v1beta2"
  ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  meta = {
    description = "BigQuery Storage API API client library";
    homepage = "https://github.com/googleapis/python-bigquery-storage";
    changelog = "https://github.com/googleapis/python-bigquery-storage/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "fixup_bigquery_storage_v1_keywords.py";
  };
}
