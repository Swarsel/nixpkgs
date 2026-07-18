{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-cov-stub,
  pytestCheckHook,
  requests,
  responses,
  setuptools,
}:

buildPythonPackage rec {
  pname = "googlemaps";
  version = "4.10.0";

  src = fetchFromGitHub {
    owner = "googlemaps";
    repo = "google-maps-services-python";
    tag = "v${version}";
    hash = "sha256-8oGZEMKUGaDHKq4qIZy10cbLNMmVclJnQE/dx877pNQ=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
    responses
  ];

  build-system = [ setuptools ];

  dependencies = [
    requests
  ];

  disabledTests = [
    # touches network
    "test_elevation_along_path_single"
    "test_transit_without_time"
  ];

  pyproject = true;
  pythonImportsCheck = [ "googlemaps" ];

  meta = {
    description = "Python client library for Google Maps API Web Services";
    homepage = "https://github.com/googlemaps/google-maps-services-python";
    changelog = "https://github.com/googlemaps/google-maps-services-python/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ Scriptkiddi ];
  };
}
