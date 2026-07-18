{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # passthru
  gitUpdater,
  # build system
  hatchling,
  # dependencies
  langgraph-checkpoint,
  ormsgpack,
  # testing
  pgvector,
  postgresql,
  postgresqlTestHook,
  psycopg,
  psycopg-pool,
  pytest-asyncio,
  pytestCheckHook,
  stdenvNoCC,
}:

buildPythonPackage (finalAttrs: {
  pname = "langgraph-checkpoint-postgres";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langgraph";
    tag = "checkpointpostgres==${finalAttrs.version}";
    hash = "sha256-xSYJ9D86GuaJEgQYk+pkJ4O7HK6HXfAOGBv4f1CBY5g=";
  };

  doCheck = !(stdenvNoCC.hostPlatform.isDarwin);

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    (postgresql.withPackages (p: [ pgvector ]))
    postgresqlTestHook
  ];

  preCheck = ''
    export postgresqlTestUserOptions="LOGIN SUPERUSER"
  '';

  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    langgraph-checkpoint
    ormsgpack
    psycopg
    psycopg-pool
  ];

  disabledTests = [
    # psycopg.errors.FeatureNotSupported: extension "vector" is not available
    # /nix/store/...postgresql-and-plugins-16.4/share/postgresql/extension/vector.control": No such file or directory.
    "test_embed_with_path"
    "test_embed_with_path_sync"
    "test_scores"
    "test_search_sorting"
    "test_vector_store_initialization"
    "test_vector_insert_with_auto_embedding"
    "test_vector_update_with_embedding"
    "test_vector_search_with_filters"
    "test_vector_search_pagination"
    "test_vector_search_edge_cases"
    "test_non_ascii"
    # Flaky under a parallel build (database in use)
    "test_store_ttl"
  ];

  postgresqlTestSetupPost = ''
    substituteInPlace tests/conftest.py \
      --replace-fail "DEFAULT_URI = \"postgres://postgres:postgres@localhost:5441/postgres?sslmode=disable\"" "DEFAULT_URI = \"postgres:///$PGDATABASE\"" \
      --replace-fail "DEFAULT_POSTGRES_URI = \"postgres://postgres:postgres@localhost:5441/\"" "DEFAULT_POSTGRES_URI = \"postgres:///\""
  '';

  pyproject = true;
  pythonImportsCheck = [ "langgraph.checkpoint.postgres" ];

  pythonRelaxDeps = [
    "langgraph-checkpoint"
    "psycopg-pool"
  ];

  sourceRoot = "${finalAttrs.src.name}/libs/checkpoint-postgres";

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "checkpointpostgres==";
    };
  };

  meta = {
    description = "Library with a Postgres implementation of LangGraph checkpoint saver";
    homepage = "https://github.com/langchain-ai/langgraph/tree/main/libs/checkpoint-postgres";
    changelog = "https://github.com/langchain-ai/langgraph/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      sarahec
    ];
  };
})
