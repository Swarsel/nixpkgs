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
  langchain-openai,
  # testing
  langchain-tests,
  pytest-asyncio,
  pytestCheckHook,
  syrupy,
}:

buildPythonPackage rec {
  pname = "langchain-deepseek";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langchain";
    tag = "langchain-deepseek==${version}";
    hash = "sha256-IHWTArtJB/CLIk0tKirRxUPcdJiqf1NDXn5Y+HBYv/g=";
  };

  nativeCheckInputs = [
    langchain-tests
    pytestCheckHook
    pytest-asyncio
    syrupy
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    langchain-core
    langchain-openai
  ];

  enabledTestPaths = [ "tests/unit_tests" ];
  pyproject = true;
  pythonImportsCheck = [ "langchain_deepseek" ];

  pythonRelaxDeps = [
    # Each component release requests the exact latest core.
    # That prevents us from updating individual components.
    "langchain-core"
  ];

  sourceRoot = "${src.name}/libs/partners/deepseek";

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "langchain-deepseek==";
    };
  };

  meta = {
    description = "Integration package connecting DeepSeek and LangChain";
    homepage = "https://github.com/langchain-ai/langchain/tree/master/libs/partners/deepseek";
    changelog = "https://github.com/langchain-ai/langchain/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sarahec ];
  };
}
