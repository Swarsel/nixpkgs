{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  execnet,
  fetchpatch,
  filelock,
  psutil,
  pytest,
  pytestCheckHook,
  setproctitle,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pytest-xdist";
  version = "3.8.0";

  src = fetchFromGitHub {
    owner = "pytest-dev";
    repo = "pytest-xdist";
    tag = "v${version}";
    hash = "sha256-2x3znm92wo8DCshf5sYK0stnESg0oVXbxsWRAaTj6oQ=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-BQfcr5f4S+e8xZP2UQwr65hp+iVzmbXYAzO/7iE9lmw=";
      name = "pytest9-compat-1.patch";
      url = "https://github.com/pytest-dev/pytest-xdist/commit/44f4bea2652e06e7cd5d4a063aa2673b5ef701ee.patch";
    })
    (fetchpatch {
      hash = "sha256-zxdKy7Z0m5UB4qwmdrolSYeBUTgMe2bQkkeX+M0RRHs=";
      name = "pytest9-compat-2.patch";
      url = "https://github.com/pytest-dev/pytest-xdist/commit/0c984478f39d7a01aa24c061f2581bdfd071cb6a.patch";
    })
  ];

  buildInputs = [ pytest ];

  nativeCheckInputs = [
    filelock
    pytestCheckHook
  ];

  # pytest can already use xdist at this point
  preCheck = ''
    appendToVar pytestFlags "--numprocesses=$NIX_BUILD_CORES"
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ execnet ];

  # access file system
  disabledTests = [
    "test_distribution_rsyncdirs_example"
    "test_rsync_popen_with_path"
    "test_popen_rsync_subdir"
    "test_rsync_report"
    "test_init_rsync_roots"
    "test_rsyncignore"
    # flakey
    "test_internal_errors_propagate_to_controller"
    # https://github.com/pytest-dev/pytest-xdist/issues/985
    "test_workqueue_ordered_by_size"
    # https://github.com/pytest-dev/pytest-xdist/issues/1248
    "test_workqueue_ordered_by_input"
  ];

  optional-dependencies = {
    psutil = [ psutil ];
    setproctitle = [ setproctitle ];
  };

  pyproject = true;
  setupHook = ./setup-hook.sh;

  meta = {
    description = "Pytest plugin for distributed testing";
    homepage = "https://github.com/pytest-dev/pytest-xdist";
    changelog = "https://github.com/pytest-dev/pytest-xdist/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
