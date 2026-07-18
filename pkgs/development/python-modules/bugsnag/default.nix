{
  lib,
  fetchFromGitHub,
  blinker,
  buildPythonPackage,
  flask,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  webob,
}:

buildPythonPackage rec {
  pname = "bugsnag";
  version = "4.9.1";

  src = fetchFromGitHub {
    owner = "bugsnag";
    repo = "bugsnag-python";
    tag = "v${version}";
    hash = "sha256-32dq68MCvfQztCwwtGD2qRQfLSEnog+HEtq/Zei0JXI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];
  dependencies = [ webob ];

  disabledTestPaths = [
    # Extra dependencies
    "tests/integrations"
    # Flaky due to timeout
    "tests/test_client.py::ClientTest::test_flush_waits_for_outstanding_events_before_returning"
    # Flaky due to timeout
    "tests/test_client.py::ClientTest::test_flush_waits_for_outstanding_sessions_before_returning"
    # Flaky failure due to AssertionError: assert 0 == 3
    "tests/test_client.py::ClientTest::test_aws_lambda_handler_decorator_warns_of_potential_timeout"
    # Flaky failure due to AssertionError: assert 0 == 1
    "tests/test_client.py::ClientTest::test_exception_hook_does_not_leave_a_breadcrumb_if_errors_are_disabled"
  ];

  optional-dependencies = {
    flask = [
      blinker
      flask
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "bugsnag" ];

  meta = {
    description = "Automatic error monitoring for Python applications";
    homepage = "https://github.com/bugsnag/bugsnag-python";
    changelog = "https://github.com/bugsnag/bugsnag-python/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
