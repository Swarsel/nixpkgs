{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-freezer,
  pytest-mock,
  pytestCheckHook,
  python-dateutil,
  pythonOlder,
  requests,
  requests-mock,
  setuptools,
  setuptools-scm,
  syrupy,
  websocket-client,
  zeroconf,
}:

buildPythonPackage rec {
  pname = "devolo-home-control-api";
  version = "0.19.1";

  src = fetchFromGitHub {
    owner = "2Fake";
    repo = "devolo_home_control_api";
    tag = "v${version}";
    hash = "sha256-IvS3582CaFf+Nfbj0rHGn6OlQ04o9EBYW+7Umbc6rpg=";
  };

  nativeCheckInputs = [
    pytest-freezer
    pytest-mock
    pytestCheckHook
    requests-mock
    syrupy
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    python-dateutil
    requests
    zeroconf
    websocket-client
  ];

  disabled = pythonOlder "3.12";

  disabledTests = [
    # Disable test that requires network access
    "test__on_pong"
    "TestMprm"
  ];

  pyproject = true;

  pytestFlags = [
    "--snapshot-update"
  ];

  pythonImportsCheck = [ "devolo_home_control_api" ];

  meta = {
    description = "Python library to work with devolo Home Control";
    homepage = "https://github.com/2Fake/devolo_home_control_api";
    changelog = "https://github.com/2Fake/devolo_home_control_api/blob/${src.tag}/docs/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
