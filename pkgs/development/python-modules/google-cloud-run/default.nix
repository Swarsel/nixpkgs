{
  lib,
  buildPythonPackage,
  fetchPypi,
  google-api-core,
  google-auth,
  grpc-google-iam-v1,
  grpcio,
  proto-plus,
  protobuf,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "google-cloud-run";
  version = "0.16.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-Vov3/Ouo+ESjm2mFio5kL2zKJ+q3JGxiHZ00HCibEVg=";
    pname = "google_cloud_run";
  };

  # Tests are only available in the google-cloud-python monorepo
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    google-api-core
    google-auth
    grpc-google-iam-v1
    grpcio
    proto-plus
    protobuf
  ];

  pyproject = true;
  pythonImportsCheck = [ "google.cloud.run" ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  meta = {
    description = "Google Cloud Run API client library";
    homepage = "https://pypi.org/project/google-cloud-run/";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/google-cloud-run-v${finalAttrs.version}/packages/google-cloud-run/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
