{
  lib,
  buildPythonPackage,
  fetchPypi,
  googleapis-common-protos,
  protobuf,
  setuptools,
}:

buildPythonPackage rec {
  pname = "google-cloud-audit-log";
  version = "0.6.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-TdNDaDwLsxGH6+80JoA/ExWelQ++o/5gqGSFXP7ZWbg=";
    pname = "google_cloud_audit_log";
  };

  # Tests are a bit wonky to setup and are not very deep either
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    googleapis-common-protos
    protobuf
  ];

  pyproject = true;
  pythonImportsCheck = [ "google.cloud.audit" ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  meta = {
    description = "Google Cloud Audit Protos";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-audit-log";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/google-cloud-audit-log-v${version}/packages/google-cloud-audit-log/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
