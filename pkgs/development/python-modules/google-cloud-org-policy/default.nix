{
  lib,
  buildPythonPackage,
  fetchPypi,
  google-api-core,
  proto-plus,
  protobuf,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "google-cloud-org-policy";
  version = "1.18.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-QeMwz8gzhj0QprX1/6oqEtD+Lwj6A9YZ+qrXRK6Nkis=";
    pname = "google_cloud_org_policy";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  # Prevent google directory from shadowing google imports
  preCheck = ''
    rm -r google
  '';

  build-system = [ setuptools ];

  dependencies = [
    google-api-core
    proto-plus
    protobuf
  ]
  ++ google-api-core.optional-dependencies.grpc;

  pyproject = true;
  pythonImportsCheck = [ "google.cloud.orgpolicy" ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  meta = {
    description = "Python Client for Organization Policy";
    homepage = "https://github.com/googleapis/google-cloud-python/blob/main/packages/${finalAttrs.pname}";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/${finalAttrs.pname}-v${finalAttrs.version}/packages/${finalAttrs.pname}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ austinbutler ];
  };
})
