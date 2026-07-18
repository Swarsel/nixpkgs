{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gitUpdater,
  # build-system
  hatchling,
  langchain-mongodb,
  # dependencies
  langgraph-checkpoint,
  pymongo,
}:

buildPythonPackage (finalAttrs: {
  pname = "langgraph-checkpoint-mongodb";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langchain-mongodb";
    tag = "libs/langgraph-checkpoint-mongodb/v${finalAttrs.version}";
    hash = "sha256-AdTAyMHNzkuvNB7DsbWxAxNKNqSxdgYwIB5UHBAAxZc=";
  };

  # Connection refused (to localhost:27017) for all tests
  doCheck = false;

  build-system = [
    hatchling
  ];

  dependencies = [
    langgraph-checkpoint
    langchain-mongodb
    pymongo
  ];

  enabledTestPaths = [ "tests/unit_tests" ];
  pyproject = true;
  # no pythonImportsCheck as this package does not provide any direct imports
  pythonImportsCheck = [ "langgraph.checkpoint.mongodb" ];

  pythonRelaxDeps = [
    "pymongo"
  ];

  sourceRoot = "${finalAttrs.src.name}/libs/langgraph-checkpoint-mongodb";

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "libs/langgraph-checkpoint-mongodb/v";
    };
  };

  meta = {
    description = "Integrations between MongoDB, Atlas, LangChain, and LangGraph";
    homepage = "https://github.com/langchain-ai/langchain-mongodb/tree/main/libs/langgraph-checkpoint-mongodb";
    changelog = "https://github.com/langchain-ai/langchain-mongodb/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sarahec ];
  };
})
