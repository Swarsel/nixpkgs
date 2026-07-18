{
  lib,
  buildPythonPackage,
  fetchPypi,
  google-api-core,
  google-cloud-core,
  mock,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "google-cloud-runtimeconfig";
  version = "0.36.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-+pDFyELolBTJfz/RIoNbGNHC30tyKhZ7D6XiQTKO2t0=";
    pname = "google_cloud_runtimeconfig";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  # prevent google directory from shadowing google imports
  preCheck = ''
    rm -r google
  '';

  build-system = [ setuptools ];

  dependencies = [
    google-api-core
    google-cloud-core
  ];

  # Client tests require credentials
  disabledTests = [ "client_options" ];
  pyproject = true;
  pythonImportsCheck = [ "google.cloud.runtimeconfig" ];

  meta = {
    description = "Google Cloud RuntimeConfig API client library";
    homepage = "https://github.com/googleapis/python-runtimeconfig";
    changelog = "https://github.com/googleapis/python-runtimeconfig/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
