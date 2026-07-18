{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  google-api-core,
  google-cloud-logging,
  # testing
  google-cloud-testutils,
  mock,
  proto-plus,
  protobuf,
  pytest-asyncio,
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "google-cloud-error-reporting";
  version = "1.14.0";

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "python-error-reporting";
    tag = "v${version}";
    hash = "sha256-do/pxm+Bo2c57ehg1cRlpax+UggSUMv8WSK30sXhHpo=";
  };

  nativeCheckInputs = [
    google-cloud-testutils
    mock
    pytest-asyncio
    pytestCheckHook
  ];

  preCheck = ''
    # prevent google directory from shadowing google imports
    rm -r google
  '';

  build-system = [ setuptools ];

  dependencies = [
    google-api-core
    google-cloud-logging
    proto-plus
    protobuf
  ]
  ++ google-api-core.optional-dependencies.grpc;

  disabledTests = [
    # Tests require credentials
    "test_report_error_event"
    "test_report_exception"
    # Import is already tested
    "test_namespace_package_compat"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "google.cloud.error_reporting"
    "google.cloud.errorreporting_v1beta1"
  ];

  pythonRelaxDeps = [ "protobuf" ];

  meta = {
    description = "Stackdriver Error Reporting API client library";
    homepage = "https://github.com/googleapis/python-error-reporting";
    changelog = "https://github.com/googleapis/python-error-reporting/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sarahec ];
  };
}
