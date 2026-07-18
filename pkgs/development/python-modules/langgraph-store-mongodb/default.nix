{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatchling,
  langchain-mongodb,
  # dependencies
  langgraph-checkpoint,
  nix-update-script,
}:

buildPythonPackage (finalAttrs: {
  pname = "langgraph-store-mongodb";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langchain-mongodb";
    tag = "libs/langgraph-store-mongodb/v${finalAttrs.version}";
    hash = "sha256-uivrfCTUu7Pq/ncAGH6HUzgyOGRcOzsQ+SVN6wW33tQ=";
  };

  # Connection Refused (to mongodb://localhost:27017)
  # Note that `langchain-mongodb` runs the same tests with mocks.
  doCheck = false;

  build-system = [
    hatchling
  ];

  dependencies = [
    langgraph-checkpoint
    langchain-mongodb
  ];

  pyproject = true;
  pythonImportsCheck = [ "langgraph.store.mongodb" ];
  sourceRoot = "${finalAttrs.src.name}/libs/langgraph-store-mongodb";

  # updater script selects wrong tag
  passthru = {
    skipBulkUpdate = true;

    updateScript = nix-update-script {
      extraArgs = [
        "-vr"
        "libs/langgraph-store-mongodb/v(.*)"
      ];
    };
  };

  meta = {
    description = "Integrations between MongoDB, Atlas, LangChain, and LangGraph";
    homepage = "https://github.com/langchain-ai/langchain-mongodb/tree/main/libs/langgraph-store-mongodb";
    changelog = "https://github.com/langchain-ai/langchain-mongodb/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sarahec ];
  };
})
