{
  lib,
  buildPythonPackage,
  fetchPypi,
  google-api-core,
  libcst,
  mock,
  proto-plus,
  protobuf,
  pytest-asyncio,
  pytestCheckHook,
  pytz,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "google-cloud-bigquery-datatransfer";
  version = "3.21.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-zVgZBASf80Iv4RPHFa9Oy7E8+/UqU+l63UH6nl6+SHA=";
    pname = "google_cloud_bigquery_datatransfer";
  };

  nativeCheckInputs = [
    mock
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    google-api-core
    libcst
    proto-plus
    protobuf
    pytz
  ]
  ++ google-api-core.optional-dependencies.grpc;

  disabledTests = [
    # Tests require project ID
    "test_list_data_sources"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "google.cloud.bigquery_datatransfer"
    "google.cloud.bigquery_datatransfer_v1"
  ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  meta = {
    description = "BigQuery Data Transfer API client library";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-bigquery-datatransfer";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/google-cloud-bigquery-datatransfer-v${finalAttrs.version}/packages/google-cloud-bigquery-datatransfer/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
