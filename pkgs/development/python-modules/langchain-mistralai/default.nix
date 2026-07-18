{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # passthru
  gitUpdater,
  # build-system
  hatchling,
  httpx,
  httpx-sse,
  # dependencies
  langchain-core,
  # tests
  langchain-tests,
  pydantic,
  pytest-asyncio,
  pytestCheckHook,
  tokenizers,
}:

buildPythonPackage (finalAttrs: {
  pname = "langchain-mistralai";
  version = "1.1.6";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langchain";
    tag = "langchain-mistralai==${finalAttrs.version}";
    hash = "sha256-FkldUvLhbOS0FwRQaAZHebUv1jUSWMXMuIx780B6R+8=";
  };

  nativeCheckInputs = [
    langchain-tests
    pytest-asyncio
    pytestCheckHook
  ];

  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    langchain-core
    tokenizers
    httpx
    httpx-sse
    pydantic
  ];

  disabledTests = [
    # Comparison error due to message formatting differences
    "test__convert_dict_to_message_tool_call"
    # Fails when langchain-core gets ahead of this package
    "test_serdes"
    # RuntimeError: Cannot send a request, as the client has been closed.
    # Tries to download from huggingface hub
    "test_mistral_init"
  ];

  enabledTestPaths = [ "tests/unit_tests" ];
  pyproject = true;
  pythonImportsCheck = [ "langchain_mistralai" ];
  sourceRoot = "${finalAttrs.src.name}/libs/partners/mistralai";

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "langchain-mistralai==";
    };
  };

  meta = {
    description = "Build LangChain applications with mistralai";
    homepage = "https://github.com/langchain-ai/langchain/tree/master/libs/partners/mistralai";
    changelog = "https://github.com/langchain-ai/langchain/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = [
      lib.maintainers.sarahec
    ];
  };
})
