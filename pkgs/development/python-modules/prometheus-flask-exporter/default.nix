{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flask,
  prometheus-client,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "prometheus-flask-exporter";
  version = "0.23.2";

  src = fetchFromGitHub {
    owner = "rycus86";
    repo = "prometheus_flask_exporter";
    tag = version;
    hash = "sha256-fWCIthtBiPJwn/Mbbwdv2+1cr9nlpUsPE2mDkaSsfpM=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    flask
    prometheus-client
  ];

  disabledTests = [
    # AssertionError
    "test_group_by_lambda_is_not_supported"
    # prometheus-client 0.24 moved CONTENT_TYPE_LATEST to version=1.0.0 while choose_encoder still defaults to 0.0.4
    "test_default_format"
  ];

  enabledTestPaths = [ "tests/" ];
  pyproject = true;

  meta = {
    description = "Prometheus exporter for Flask applications";
    homepage = "https://github.com/rycus86/prometheus_flask_exporter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lbpdt ];
  };
}
