{
  lib,
  stdenv,
  fetchFromGitHub,
  aiosqlite,
  birch,
  buildPythonPackage,
  click,
  dnspython,
  pandas,
  portalocker,
  pymongo,
  pymongo-inmemory,
  pympler,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  sqlalchemy,
  watchdog,
}:

buildPythonPackage rec {
  pname = "cachier";
  version = "4.2.0";

  src = fetchFromGitHub {
    owner = "python-cachier";
    repo = "cachier";
    tag = "v${version}";
    hash = "sha256-hiyevLMtKV8M8znB2mznHLRM+pVN6uCxZZVf3H0gjTI=";
  };

  nativeBuildInputs = [
    setuptools
  ];

  preBuild = ''
    export HOME="$(mktemp -d)"
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    pytest-asyncio
    aiosqlite
    sqlalchemy
    pymongo
    dnspython
    pymongo-inmemory
    pandas
    birch
  ];

  dependencies = [
    watchdog
    pympler
    portalocker
    # not listed as dep, but needed to run main script entrypoint
    click
  ];

  disabledTestPaths = [
    # Keeps breaking due to concurrent access or failing to close the db between tests.
    "tests/sql_tests/test_sql_core.py"
  ];

  disabledTests = [
    # touches network
    "test_mongetter_default_param"
    "test_stale_after_applies_dynamically"
    "test_next_time_applies_dynamically"
    "test_wait_for_calc_"
    "test_precache_value"
    "test_ignore_self_in_methods"
    "test_mongo_index_creation"
    "test_mongo_core"

    # don't test formatting
    "test_flake8"

    # slow, spawns 800+ threads
    "test_inotify_instance_limit_reached"

    # timing sensitive
    "test_being_calc_next_time"
    "test_pickle_being_calculated"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # sensitive to host file system
    # Unhandled exception in FSEventsEmitter -  RuntimeError: Cannot add watch - it is already scheduled
    "test_bad_cache_file"
    "test_delete_cache_file"
  ];

  pyproject = true;
  pythonImportsCheck = [ "cachier" ];
  pythonRemoveDeps = [ "setuptools" ];

  meta = {
    description = "Persistent, stale-free, local and cross-machine caching for functions";
    homepage = "https://github.com/python-cachier/cachier";
    changelog = "https://github.com/python-cachier/cachier/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pbsds ];
    mainProgram = "cachier";
  };
}
