{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  flask,
  # buildInputs
  pytest,
  # tests
  pytestCheckHook,
  pythonAtLeast,
  # build-system
  setuptools-scm,
  werkzeug,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytest-flask";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "pytest-dev";
    repo = "pytest-flask";
    tag = finalAttrs.version;
    hash = "sha256-mcBHpP6A+ehqowDccfcn+wv6WXRrF0cY9ez7kqkb3Hc=";
  };

  buildInputs = [ pytest ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools-scm ];

  dependencies = [
    flask
    werkzeug
  ];

  disabledTests = lib.optionals (pythonAtLeast "3.14") [
    # Failed: nomatch: '*PASSED*'
    "test_add_endpoint_to_live_server"
    "test_clean_stop_live_server"
    "test_live_server_fixed_host"
    "test_live_server_fixed_port"
    "test_rewrite_application_server_name"
    "test_start_live_server"

    # _pickle.PicklingError: Can't pickle local object
    "test_init"
    "test_server_is_alive"
    "test_server_listening"
    "test_set_application_server_name"
    "test_stop_cleanly_join_exception"
    "test_url_for"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_flask" ];

  meta = {
    description = "Set of pytest fixtures to test Flask applications";
    homepage = "https://pytest-flask.readthedocs.io/";
    changelog = "https://github.com/pytest-dev/pytest-flask/blob/${finalAttrs.src.tag}/docs/changelog.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vanschelven ];
  };
})
