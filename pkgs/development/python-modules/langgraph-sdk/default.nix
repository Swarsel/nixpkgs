{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # passthru
  gitUpdater,
  # build-system
  hatchling,
  # dependencies
  httpx,
  httpx-sse,
  langchain-core,
  langchain-protocol,
  orjson,
  typing-extensions,
  websockets,
}:

buildPythonPackage (finalAttrs: {
  pname = "langgraph-sdk";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langgraph";
    tag = "sdk==${finalAttrs.version}";
    hash = "sha256-30BY7f8m3YiqEBhb3+TQYTW0N40xI9kTQbMTh4BwcyU=";
  };

  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    httpx
    httpx-sse
    langchain-core
    langchain-protocol
    orjson
    typing-extensions
    websockets
  ];

  disabledTests = [ "test_aevaluate_results" ]; # Compares execution time to magic number
  pyproject = true;
  pythonImportsCheck = [ "langgraph_sdk" ];
  pythonRelaxDeps = [ "websockets" ];
  sourceRoot = "${finalAttrs.src.name}/libs/sdk-py";

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "sdk==";
    };
  };

  meta = {
    description = "SDK for interacting with the LangGraph Cloud REST API";
    homepage = "https://github.com/langchain-ai/langgraph/tree/main/libs/sdk-py";
    changelog = "https://github.com/langchain-ai/langgraph/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sarahec ];
  };
})
