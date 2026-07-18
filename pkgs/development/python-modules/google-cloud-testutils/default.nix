{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  google-auth,
  packaging,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "google-cloud-testutils";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "python-test-utils";
    tag = "v${version}";
    hash = "sha256-g7XwDQp4c+duKfUWqhnI8T001fu6cM22oWLriyCZZag=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    click
    google-auth
    packaging
  ];

  pyproject = true;
  pythonImportsCheck = [ "test_utils" ];

  meta = {
    description = "System test utilities for google-cloud-python";
    homepage = "https://github.com/googleapis/python-test-utils";
    changelog = "https://github.com/googleapis/python-test-utils/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sarahec ];
    mainProgram = "lower-bound-checker";
  };
}
