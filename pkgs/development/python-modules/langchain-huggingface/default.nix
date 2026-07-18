{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  freezegun,
  # passthru
  gitUpdater,
  # build-system
  hatchling,
  httpx,
  # dependencies
  huggingface-hub,
  langchain-core,
  lark,
  pandas,
  pytest-asyncio,
  pytest-mock,
  pytest-socket,
  pytestCheckHook,
  requests-mock,
  responses,
  sentence-transformers,
  syrupy,
  tokenizers,
  toml,
  transformers,
}:

buildPythonPackage (finalAttrs: {
  pname = "langchain-huggingface";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langchain";
    tag = "langchain-huggingface==${finalAttrs.version}";
    hash = "sha256-jMbFqui0XoKZ15B+5kJAamW5Dasv/JCIZS2KtteRBXg=";
  };

  nativeCheckInputs = [
    freezegun
    httpx
    lark
    pandas
    pytest-asyncio
    pytest-mock
    pytest-socket
    pytestCheckHook
    requests-mock
    responses
    syrupy
    toml
  ];

  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    huggingface-hub
    langchain-core
    sentence-transformers
    tokenizers
    transformers
  ];

  disabledTests = [
    # Requires a circular dependency on langchain
    "test_init_chat_model_huggingface"
    # AssertionError: Expected 'bind' to have been called once. Called 0 times.
    "test_bind_tools"
  ];

  enabledTestPaths = [ "tests/unit_tests" ];
  pyproject = true;
  pythonImportsCheck = [ "langchain_huggingface" ];
  sourceRoot = "${finalAttrs.src.name}/libs/partners/huggingface";

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "langchain-huggingface==";
    };
  };

  meta = {
    description = "Integration package connecting Huggingface related classes and LangChain";
    homepage = "https://github.com/langchain-ai/langchain/tree/master/libs/partners/huggingface";
    changelog = "https://github.com/langchain-ai/langchain/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      natsukium
      sarahec
    ];
  };
})
