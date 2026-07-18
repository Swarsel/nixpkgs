{
  lib,
  fetchFromGitHub,
  # dependencies
  aiosqlite,
  buildPythonPackage,
  # passthru
  gitUpdater,
  # build system
  hatchling,
  langgraph-checkpoint,
  # testing
  pytest-asyncio,
  pytestCheckHook,
  sqlite,
  sqlite-vec,
}:

buildPythonPackage (finalAttrs: {
  pname = "langgraph-checkpoint-sqlite";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langgraph";
    tag = "checkpointsqlite==${finalAttrs.version}";
    hash = "sha256-xSYJ9D86GuaJEgQYk+pkJ4O7HK6HXfAOGBv4f1CBY5g=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    sqlite
  ];

  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    aiosqlite
    langgraph-checkpoint
    sqlite-vec
  ];

  disabledTestPaths = [
    # Failed: 'flaky' not found in `markers` configuration option
    "tests/test_ttl.py"
  ];

  disabledTests = [
    # AssertionError: (fails object comparison due to extra runtime fields)
    # https://github.com/langchain-ai/langgraph/issues/5604
    "test_combined_metadata"
    "test_asearch"
    "test_search"
  ];

  pyproject = true;
  pythonImportsCheck = [ "langgraph.checkpoint.sqlite" ];

  pythonRelaxDeps = [
    "aiosqlite"

    # Bug: version is showing up as 0.0.0
    # https://github.com/NixOS/nixpkgs/issues/427197
    "sqlite-vec"

    # Checkpoint clients are lagging behind langgraph-checkpoint
    "langgraph-checkpoint"
  ];

  sourceRoot = "${finalAttrs.src.name}/libs/checkpoint-sqlite";

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "checkpointsqlite==";
    };
  };

  meta = {
    description = "Library with a SQLite implementation of LangGraph checkpoint saver";
    homepage = "https://github.com/langchain-ai/langgraph/tree/main/libs/checkpoint-sqlite";
    changelog = "https://github.com/langchain-ai/langgraph/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      sarahec
    ];
  };
})
