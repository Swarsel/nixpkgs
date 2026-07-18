{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  click,
  docker-compose,
  # passthru
  gitUpdater,
  # build-system
  hatchling,
  httpx,
  langgraph,
  langgraph-runtime-inmem,
  langgraph-sdk,
  pathspec,
  # testing
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
  python-dotenv,
}:

buildPythonPackage (finalAttrs: {
  pname = "langgraph-cli";
  version = "0.4.30";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langgraph";
    tag = "cli==${finalAttrs.version}";
    hash = "sha256-wemTtMT8UbpEsGzf0fMnXdhJv0oTrG/TqEu6HhFN6nc=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-mock
    pytestCheckHook
    docker-compose
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    click
    httpx
    langgraph-sdk
    pathspec
    python-dotenv
  ];

  disabledTests = [
    # Flaky tests that generate a Docker configuration then compare to exact text
    "test_config_to_docker_simple"
    "test_config_to_docker_pipconfig"
    "test_config_to_compose_env_vars"
    "test_config_to_compose_env_file"
    "test_config_to_compose_end_to_end"
    "test_config_to_compose_simple_config"
    "test_config_to_compose_watch"

    # Tests that require docker
    "test_dockerfile_command_with_docker_compose"
    "test_build_command_with_api_version_and_base_image"
    "test_build_command_with_api_version"
    "test_build_generate_proper_build_context"
    "test_build_command_shows_wolfi_warning"
  ];

  enabledTestPaths = [ "tests/unit_tests" ];

  optional-dependencies = {
    "inmem" = [
      langgraph
      langgraph-runtime-inmem
      python-dotenv
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "langgraph_cli" ];
  sourceRoot = "${finalAttrs.src.name}/libs/cli";

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "cli==";
    };
  };

  meta = {
    description = "Official CLI for LangGraph API";
    homepage = "https://github.com/langchain-ai/langgraph/tree/main/libs/cli";
    changelog = "https://github.com/langchain-ai/langgraph/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sarahec ];
    mainProgram = "langgraph";
  };
})
