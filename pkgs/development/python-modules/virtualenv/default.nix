{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  distlib,
  filelock,
  flaky,
  hatch-vcs,
  hatchling,
  isPyPy,
  platformdirs,
  pytest-freezer,
  pytest-mock,
  pytestCheckHook,
  python-discovery,
  time-machine,
}:

buildPythonPackage rec {
  pname = "virtualenv";
  version = "21.2.4";

  src = fetchFromGitHub {
    owner = "pypa";
    repo = "virtualenv";
    tag = version;
    hash = "sha256-3Ed2h5zzjpm+D1fQW2urWYcO/6sFGuZtueQxUnIu3MY=";
  };

  nativeCheckInputs = [
    flaky
    pytest-mock
    pytestCheckHook
  ]
  ++ lib.optionals isPyPy [ pytest-freezer ]
  ++ lib.optionals (!isPyPy) [ time-machine ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    distlib
    filelock
    platformdirs
    python-discovery
  ];

  disabledTestPaths = [
    # Ignore tests which require network access
    "tests/unit/create/test_creator.py"
    "tests/unit/create/via_global_ref/test_build_c_ext.py"
  ];

  disabledTests = [
    # Network access
    "test_seed_link_via_app_data"
  ]
  ++ lib.optionals isPyPy [
    # encoding problems
    "test_bash"
    # permission error
    "test_can_build_c_extensions"
    # fails to detect pypy version
    "test_discover_ok"
    # type error
    "test_fallback_existent_system_executable"
  ];

  pyproject = true;
  pythonImportsCheck = [ "virtualenv" ];

  meta = {
    description = "Tool to create isolated Python environments";
    homepage = "http://www.virtualenv.org";
    changelog = "https://github.com/pypa/virtualenv/blob/${version}/docs/changelog.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "virtualenv";
  };
}
