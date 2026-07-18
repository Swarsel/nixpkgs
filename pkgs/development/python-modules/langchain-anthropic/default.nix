{
  lib,
  fetchFromGitHub,
  # dependencies
  anthropic,
  # tests
  blockbuster,
  buildPythonPackage,
  # passthru
  gitUpdater,
  # build-system
  hatchling,
  langchain,
  langchain-core,
  langchain-tests,
  pydantic,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "langchain-anthropic";
  version = "1.4.8";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langchain";
    tag = "langchain-anthropic==${finalAttrs.version}";
    hash = "sha256-MX+DhFEkRNZ3IEKMXFT61XR6hEx2WPdGGaA0b/KlPZE=";
  };

  nativeCheckInputs = [
    blockbuster
    langchain
    langchain-tests
    pytest-asyncio
    pytestCheckHook
  ];

  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    anthropic
    langchain-core
    pydantic
  ];

  disabledTests = [
    # Fails when langchain-core gets ahead of this
    "test_serdes"
    # KeyError: 'versions' in 1.4.6
    "test_anthropic_model_params"
  ];

  enabledTestPaths = [
    "tests/unit_tests"
  ];

  pyproject = true;
  pythonImportsCheck = [ "langchain_anthropic" ];
  # Langchain always tracks the latest release of anthropic whether or not it's needed
  pythonRelaxDeps = [ "anthropic" ];
  sourceRoot = "${finalAttrs.src.name}/libs/partners/anthropic";

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "langchain-anthropic==";
    };
  };

  meta = {
    description = "Build LangChain applications with Anthropic";
    homepage = "https://github.com/langchain-ai/langchain/tree/master/libs/partners/anthropic";
    changelog = "https://github.com/langchain-ai/langchain/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = [
      lib.maintainers.sarahec
    ];
  };
})
