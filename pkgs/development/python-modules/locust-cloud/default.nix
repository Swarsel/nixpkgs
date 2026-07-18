{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  configargparse,
  flask,
  gevent,
  gevent-websocket,
  hatch-vcs,
  hatchling,
  platformdirs,
  pytestCheckHook,
  python-engineio,
  python-socketio,
  requests,
  requests-mock,
  tomli,
}:

buildPythonPackage rec {
  pname = "locust-cloud";
  version = "1.30.0";

  src = fetchFromGitHub {
    owner = "locustcloud";
    repo = "locust-cloud";
    tag = version;
    hash = "sha256-GJS0+CUYMz3G98I7Edj2qEsIFTp5wzsuSMmN7DlZPjA=";
  };

  nativeCheckInputs = [
    flask
    gevent-websocket
    pytestCheckHook
    requests-mock
  ];

  preCheck = ''
    export LOCUSTCLOUD_USERNAME=dummy
    export LOCUSTCLOUD_PASSWORD=dummy
  '';

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    configargparse
    gevent
    platformdirs
    python-engineio
    python-socketio
    requests
    tomli
  ];

  disabledTestPaths = [
    # Tests require network access
    "tests/web_login_test.py"
    "tests/cloud_test.py"
    "tests/websocket_test.py"
    # AssertionError
    "tests/import_finder_test.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "locust_cloud" ];

  meta = {
    description = "Hosted version of Locust to run distributed load tests";
    homepage = "https://github.com/locustcloud/locust-cloud";
    changelog = "https://github.com/locustcloud/locust-cloud/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ magicquark ];
  };
}
