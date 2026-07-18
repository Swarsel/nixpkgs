{
  lib,
  fetchFromGitHub,
  aw-core,
  buildPythonPackage,
  click,
  persist-queue,
  poetry-core,
  pytestCheckHook,
  requests,
  tabulate,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "aw-client";
  version = "0.5.15";

  src = fetchFromGitHub {
    owner = "ActivityWatch";
    repo = "aw-client";
    tag = "v${version}";
    hash = "sha256-AS29DIfEQ6/vh8idcMMQoGmiRM8MMf3eVQzvNPsXgpA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    # Fake home folder for tests that write to $HOME
    export HOME="$TMPDIR"
  '';

  build-system = [ poetry-core ];

  dependencies = [
    aw-core
    requests
    persist-queue
    click
    tabulate
    typing-extensions
  ];

  # Only run this test, the others are integration tests that require
  # an instance of aw-server running in order to function.
  enabledTestPaths = [ "tests/test_requestqueue.py" ];
  pyproject = true;
  pythonImportsCheck = [ "aw_client" ];

  meta = {
    description = "Client library for ActivityWatch";
    homepage = "https://github.com/ActivityWatch/aw-client";
    changelog = "https://github.com/ActivityWatch/aw-client/releases/tag/v${version}";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ huantian ];
    mainProgram = "aw-client";
  };
}
