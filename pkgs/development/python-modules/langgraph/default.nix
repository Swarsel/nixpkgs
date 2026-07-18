{
  lib,
  stdenv,
  fetchFromGitHub,
  # tests
  aiosqlite,
  buildPythonPackage,
  dataclasses-json,
  fakeredis,
  grandalf,
  # build-system
  hatchling,
  httpx,
  # dependencies
  langchain-core,
  langgraph-checkpoint,
  langgraph-checkpoint-postgres,
  langgraph-checkpoint-sqlite,
  langgraph-prebuilt,
  langgraph-sdk,
  langsmith,
  # passthru
  nix-update-script,
  postgresql,
  postgresqlTestHook,
  psycopg,
  pycryptodome,
  pydantic,
  pytest-asyncio,
  pytest-mock,
  pytest-repeat,
  pytest-xdist,
  pytestCheckHook,
  redisTestHook,
  syrupy,
  xxhash,
}:
buildPythonPackage (finalAttrs: {
  pname = "langgraph";
  version = "1.2.7";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langgraph";
    tag = finalAttrs.version;
    hash = "sha256-Ws84VIh+IkL1oV4PmZacu56TW+S1JppCgDtK5datLY4=";
  };

  # postgresql doesn't play nicely with the darwin sandbox:
  # FATAL:  could not create shared memory segment: Operation not permitted
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    pytestCheckHook
    postgresql
    postgresqlTestHook
    redisTestHook
    fakeredis
    langgraph-checkpoint
  ];

  checkInputs = [
    aiosqlite
    dataclasses-json
    grandalf
    httpx
    langgraph-checkpoint-postgres
    langgraph-checkpoint-sqlite
    langsmith
    psycopg
    psycopg.pool
    pycryptodome
    pydantic
    pytest-asyncio
    pytest-mock
    pytest-repeat
    pytest-xdist
    syrupy
  ];

  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    langchain-core
    langgraph-checkpoint
    langgraph-prebuilt
    langgraph-sdk
    pydantic
    xxhash
  ];

  disabledTestPaths = [
    # psycopg.errors.InsufficientPrivilege: permission denied to create database
    "tests/test_checkpoint_migration.py"
    "tests/test_large_cases.py"
    "tests/test_large_cases_async.py"
    "tests/test_pregel.py"
    "tests/test_pregel_async.py"
    "tests/test_subgraph_persistence.py"
    "tests/test_subgraph_persistence_async.py"
    "tests/test_time_travel.py"
    "tests/test_time_travel_async.py"

    # Race condition
    "tests/test_retry.py::test_error_handler_resumes_after_crash_multiple_nodes"
  ];

  disabledTests = [
    # Requires `langgraph dev` to be running
    "test_remote_graph_basic_invoke"
    "test_remote_graph_stream_messages_tuple"

    # Disabling tests that requires to create new random databases
    "test_cancel_graph_astream"
    "test_cancel_graph_astream_events_v2"
    "test_channel_values"
    "test_fork_always_re_runs_nodes"
    "test_interruption_without_state_updates"
    "test_interruption_without_state_updates_async"
    "test_invoke_two_processes_in_out_interrupt"
    "test_nested_graph_interrupts"
    "test_no_modifier_async"
    "test_no_modifier"
    "test_pending_writes_resume"
    "test_remove_message_via_state_update"
    "test_interrupt_functional_pydantic"
  ];

  postgresqlTestSetupPost = ''
    substituteInPlace tests/conftest_store.py \
      --replace-fail "DEFAULT_POSTGRES_URI = \"postgres://postgres:postgres@localhost:5442/\"" "DEFAULT_POSTGRES_URI = \"postgres:///$PGDATABASE\""
    substituteInPlace tests/conftest_checkpointer.py \
      --replace-fail "DEFAULT_POSTGRES_URI = \"postgres://postgres:postgres@localhost:5442/\"" "DEFAULT_POSTGRES_URI = \"postgres:///$PGDATABASE\""
  '';

  pyproject = true;
  pythonImportsCheck = [ "langgraph" ];
  sourceRoot = "${finalAttrs.src.name}/libs/langgraph";

  # Since `langgraph` is the only unprefixed package, we have to use an explicit match
  passthru = {
    skipBulkUpdate = true;

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "([0-9.]+)"
      ];
    };
  };

  meta = {
    description = "Build resilient language agents as graphs";
    homepage = "https://github.com/langchain-ai/langgraph";
    changelog = "https://github.com/langchain-ai/langgraph/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sarahec ];
  };
})
