{
  lib,
  fetchFromGitHub,
  # dependencies
  beautifulsoup4,
  buildPythonPackage,
  # tests
  pytestCheckHook,
  requests,
  rsa,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "steampy";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "bukson";
    repo = "steampy";
    tag = finalAttrs.version;
    hash = "sha256-dGcqJGRQ88vXy+x2U+ykutP4RnzTUqJlmhXmcr+4maE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    beautifulsoup4
    requests
    rsa
  ];

  disabledTestPaths = [
    # Require Steam credentials
    "test/test_client.py"
    "test/test_guard.py"
    "test/test_market.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "steampy" ];

  meta = {
    description = "Steam trading library";
    homepage = "https://github.com/bukson/steampy";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ artur-sannikov ];
  };
})
