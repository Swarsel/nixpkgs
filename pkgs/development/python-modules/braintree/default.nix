{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "braintree";
  version = "4.45.0";

  src = fetchFromGitHub {
    owner = "braintree";
    repo = "braintree_python";
    tag = finalAttrs.version;
    hash = "sha256-cD0TKqf2c/wdFwDc78rEPm4ucZkYS1nk2Uo0oTfcJvE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ requests ];

  # Most integration tests require a running Braintree gateway.
  enabledTestPaths = [
    "tests/unit"
    "tests/integration/test_credentials_parser.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "braintree" ];

  meta = {
    description = "Python library for integration with Braintree";
    homepage = "https://github.com/braintree/braintree_python";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
