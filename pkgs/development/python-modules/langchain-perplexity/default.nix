{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # passthru
  gitUpdater,
  # build-system
  hatchling,
  # dependencies
  langchain-core,
  # tests
  langchain-tests,
  openai,
  perplexityai,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "langchain-perplexity";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langchain";
    tag = "langchain-perplexity==${finalAttrs.version}";
    hash = "sha256-YWVTghbLE6jXrkwS9shTdDr0pp4ILEVq+dgjg9njRhA=";
  };

  nativeCheckInputs = [
    langchain-tests
    pytest-asyncio
    pytest-cov-stub
    pytest-mock
    pytestCheckHook
  ];

  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    langchain-core
    openai
    perplexityai
  ];

  enabledTestPaths = [ "tests/unit_tests" ];
  pyproject = true;
  pythonImportsCheck = [ "langchain_perplexity" ];

  pythonRelaxDeps = [
    # Each component release requests the exact latest core.
    # That prevents us from updating individual components.
    "langchain-core"
  ];

  sourceRoot = "${finalAttrs.src.name}/libs/partners/perplexity";

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "langchain-perplexity==";
    };
  };

  meta = {
    description = "Build LangChain applications with Perplexity";
    homepage = "https://github.com/langchain-ai/langchain/tree/master/libs/partners/perplexity";
    changelog = "https://github.com/langchain-ai/langchain/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      sarahec
    ];
  };
})
