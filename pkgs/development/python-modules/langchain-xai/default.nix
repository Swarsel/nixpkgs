{
  lib,
  fetchFromGitHub,
  # dependencies
  aiohttp,
  buildPythonPackage,
  # passthru
  gitUpdater,
  # build-system
  hatchling,
  langchain-core,
  langchain-openai,
  # tests
  langchain-tests,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
  requests,
}:

buildPythonPackage (finalAttrs: {
  pname = "langchain-xai";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langchain";
    tag = "langchain-xai==${finalAttrs.version}";
    hash = "sha256-RUklm627HiwMcpKkm+0uWZgHp4iDtSsmEpLb9MxumqI=";
  };

  nativeCheckInputs = [
    langchain-tests
    pytest-asyncio
    pytest-mock
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    langchain-core
    langchain-openai
    requests
  ];

  disabledTests = [
    # Breaks when langchain-core is updated
    # Also: Compares a diff to a string literal and misses platform differences (aarch64-linux)
    "test_serdes"
  ];

  enabledTestPaths = [ "tests/unit_tests" ];
  pyproject = true;
  pythonImportsCheck = [ "langchain_xai" ];
  sourceRoot = "${finalAttrs.src.name}/libs/partners/xai";

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "langchain-xai==";
    };
  };

  meta = {
    description = "Build LangChain applications with X AI";
    homepage = "https://github.com/langchain-ai/langchain/tree/master/libs/partners/xai";
    changelog = "https://github.com/langchain-ai/langchain/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = [
      lib.maintainers.sarahec
    ];
  };
})
