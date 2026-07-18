{
  lib,
  fetchFromGitHub,
  arrow,
  buildPythonPackage,
  pytest-cov-stub,
  pytest-datafiles,
  pytest-vcr,
  pytestCheckHook,
  python-box,
  requests,
  responses,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "restfly";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "stevemcgrath";
    repo = "restfly";
    tag = version;
    hash = "sha256-hHNsOFu2b4sb9zbdWVTwoU1HShLFqC+Q9/PJcEqu7Hg=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytest-datafiles
    pytest-vcr
    pytestCheckHook
    responses
  ];

  build-system = [ setuptools ];

  dependencies = [
    arrow
    python-box
    requests
    typing-extensions
  ];

  disabledTests = [
    # Test requires network access
    "test_session_ssl_error"
  ];

  pyproject = true;
  pythonImportsCheck = [ "restfly" ];

  meta = {
    description = "Python RESTfly API Library Framework";
    homepage = "https://github.com/stevemcgrath/restfly";
    changelog = "https://github.com/librestfly/restfly/blob/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
