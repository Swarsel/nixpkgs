{
  lib,
  fetchFromGitHub,
  # dependencies
  azure-identity,
  buildPythonPackage,
  # tests
  freezegun,
  # passthru
  gitUpdater,
  langchain-core,
  langchain-openai,
  lark,
  pandas,
  # build-system
  poetry-core,
  pytest-asyncio,
  pytest-mock,
  pytest-socket,
  pytestCheckHook,
  requests-mock,
  responses,
  syrupy,
  toml,
}:

buildPythonPackage rec {
  pname = "langchain-azure-dynamic-sessions";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langchain";
    tag = "langchain-azure-dynamic-sessions==${version}";
    hash = "sha256-tgvoOSr4tpi+tFBan+kw8FZUfUJHcQXv9e1nyeGP0so=";
  };

  nativeCheckInputs = [
    freezegun
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

  build-system = [ poetry-core ];

  dependencies = [
    azure-identity
    langchain-core
    langchain-openai
  ];

  enabledTestPaths = [ "tests/unit_tests" ];
  pyproject = true;
  pythonImportsCheck = [ "langchain_azure_dynamic_sessions" ];

  pythonRelaxDeps = [
    # Each component release requests the exact latest core.
    # That prevents us from updating individual components.
    "langchain-core"
  ];

  sourceRoot = "${src.name}/libs/partners/azure-dynamic-sessions";

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "langchain-azure-dynamic-sessions==";
    };
  };

  meta = {
    description = "Integration package connecting Azure Container Apps dynamic sessions and LangChain";
    homepage = "https://github.com/langchain-ai/langchain/tree/master/libs/partners/azure-dynamic-sessions";
    changelog = "https://github.com/langchain-ai/langchain/releases/tag/${src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      natsukium
      sarahec
    ];
  };
}
