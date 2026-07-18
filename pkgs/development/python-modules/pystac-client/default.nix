{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pystac,
  pytest-benchmark,
  pytest-console-scripts,
  pytest-mock,
  pytest-recording,
  pytestCheckHook,
  python-dateutil,
  requests,
  requests-mock,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pystac-client";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "stac-utils";
    repo = "pystac-client";
    tag = "v${version}";
    hash = "sha256-+DOWf1ZAwylicdSuOBNivi0Z7DxaymZF756X7fogAjc=";
  };

  nativeCheckInputs = [
    pytest-benchmark
    pytestCheckHook
    pytest-console-scripts
    pytest-mock
    pytest-recording
    requests-mock
  ];

  build-system = [ setuptools ];

  dependencies = [
    pystac
    python-dateutil
    requests
  ];

  disabledTestMarks = [
    # Tests accessing Internet
    "vcr"
  ];

  # requires cql2
  disabledTests = [
    "test_filter_conversion_to_cql2_json"
    "test_filter_conversion_to_cql2_text"
  ];

  pyproject = true;

  pytestFlags = [
    "--benchmark-disable"
  ];

  pythonImportsCheck = [ "pystac_client" ];

  meta = {
    description = "Python client for working with STAC Catalogs and APIs";
    homepage = "https://github.com/stac-utils/pystac-client";
    license = lib.licenses.asl20;
    teams = [ lib.teams.geospatial ];
  };
}
