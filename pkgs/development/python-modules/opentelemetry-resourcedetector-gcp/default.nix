{
  lib,
  buildPythonPackage,
  fetchPypi,
  opentelemetry-api,
  opentelemetry-sdk,
  pytestCheckHook,
  requests,
  setuptools,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "opentelemetry-resourcedetector-gcp";
  version = "1.12.0a0";

  # Use PyPi instead of GitHub because the GitHub tags are inaccurate
  # (GitHub tags lack the alpha suffix)
  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-1eP3goOicuuSVH4Au+/0W3Myo0rnkacKtOuoGvm8O68=";
    pname = "opentelemetry_resourcedetector_gcp";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    opentelemetry-api
    opentelemetry-sdk
    requests
    typing-extensions
  ];

  disabledTestPaths = [
    # These require a 4-year-old syrupy version
    "tests/test_mapping.py"
    "tests/test_gcp_resource_detector.py"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "opentelemetry.resourcedetector.gcp_resource_detector"
  ];

  meta = {
    description = "Google Cloud resource detector for OpenTelemetry";
    homepage = "https://pypi.org/project/opentelemetry-resourcedetector-gcp";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      sarahec
    ];
  };
})
