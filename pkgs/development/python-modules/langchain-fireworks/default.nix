{
  lib,
  fetchFromGitHub,
  # dependencies
  aiohttp,
  buildPythonPackage,
  fireworks-ai,
  # passthru
  gitUpdater,
  # build-system
  hatchling,
  langchain-core,
  # tests
  langchain-tests,
  openai,
  pydantic,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "langchain-fireworks";
  version = "1.4.3";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langchain";
    tag = "langchain-fireworks==${finalAttrs.version}";
    hash = "sha256-Z8KwSMq4kVCUVD9Cs8PU6ZRcC9ZG52dbeQrpYInt9L0=";
  };

  strictDeps = true;

  nativeCheckInputs = [
    langchain-tests
    pytest-asyncio
    pytestCheckHook
  ];

  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    fireworks-ai
    langchain-core
    openai
    pydantic
  ];

  disabledTests = [
    # Fails when langchain-core gets ahead of this package
    "test_serdes"
  ];

  enabledTestPaths = [ "tests/unit_tests" ];
  pyproject = true;
  pythonImportsCheck = [ "langchain_fireworks" ];

  pythonRelaxDeps = [
    "fireworks-ai"
    "langchain-core"
  ];

  sourceRoot = "${finalAttrs.src.name}/libs/partners/fireworks";

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "langchain-fireworks==";
    };
  };

  meta = {
    description = "Build LangChain applications with Fireworks";
    homepage = "https://github.com/langchain-ai/langchain/tree/master/libs/partners/fireworks";
    changelog = "https://github.com/langchain-ai/langchain/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      sarahec
    ];
  };
})
