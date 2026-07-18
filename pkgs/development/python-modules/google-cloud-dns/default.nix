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
  pname = "google-cloud-dns";
  version = "0.36.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Uf4riBDfgTadviwIe6KUSypgIZBeMQSOTe6cmP8fEkk=";
    pname = "google_cloud_dns";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  preCheck = ''
    # don#t shadow python imports
    rm -r google
  '';

  build-system = [ setuptools ];

  dependencies = [
    google-api-core
    google-cloud-core
  ];

  disabledTests = [
    # Test requires credentials
    "test_quota"
  ];

  pyproject = true;
  pythonImportsCheck = [ "google.cloud.dns" ];

  meta = {
    description = "Google Cloud DNS API client library";
    homepage = "https://github.com/googleapis/python-dns";
    changelog = "https://github.com/googleapis/python-dns/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
