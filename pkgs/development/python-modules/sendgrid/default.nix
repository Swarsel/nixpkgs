{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  ecdsa,
  flask,
  pytestCheckHook,
  python-http-client,
  pyyaml,
  setuptools,
  starkbank-ecdsa,
  werkzeug,
}:

buildPythonPackage rec {
  pname = "sendgrid";
  version = "6.12.5";

  src = fetchFromGitHub {
    owner = pname;
    repo = "sendgrid-python";
    tag = version;
    hash = "sha256-7r1FHcGmHRQK9mfpV3qcuZlIe7G6CIyarnpWLjduw4E=";
  };

  nativeCheckInputs = [
    flask
    pytestCheckHook
    pyyaml
    werkzeug
  ];

  build-system = [ setuptools ];

  dependencies = [
    cryptography
    ecdsa
    python-http-client
    starkbank-ecdsa
  ];

  disabledTestPaths = [
    # Exclude tests that require network access
    "test/integ/test_sendgrid.py"
    "live_test.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "sendgrid" ];
  pythonRelaxDeps = [ "cryptography" ];

  meta = {
    description = "Python client for SendGrid";
    homepage = "https://github.com/sendgrid/sendgrid-python";
    changelog = "https://github.com/sendgrid/sendgrid-python/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
