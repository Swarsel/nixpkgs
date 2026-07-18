{
  lib,
  fetchFromGitHub,
  # tests
  beautifulsoup4,
  buildPythonPackage,
  # passthru
  gitUpdater,
  # build-system
  hatchling,
  httpx,
  # dependencies
  langchain-core,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "langchain-text-splitters";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langchain";
    tag = "langchain-text-splitters==${finalAttrs.version}";
    hash = "sha256-AiRl8N2V2UfYLZfqxM8DHZmT76rH19I1gFyOYc/mpYY=";
  };

  nativeCheckInputs = [
    beautifulsoup4
    httpx
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ hatchling ];
  dependencies = [ langchain-core ];
  enabledTestPaths = [ "tests/unit_tests" ];
  pyproject = true;
  pythonImportsCheck = [ "langchain_text_splitters" ];
  sourceRoot = "${finalAttrs.src.name}/libs/text-splitters";

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "langchain-text-splitters==";
    };
  };

  meta = {
    description = "LangChain utilities for splitting into chunks a wide variety of text documents";
    homepage = "https://github.com/langchain-ai/langchain/tree/master/libs/text-splitters";
    changelog = "https://github.com/langchain-ai/langchain/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      fab
      sarahec
    ];
  };
})
