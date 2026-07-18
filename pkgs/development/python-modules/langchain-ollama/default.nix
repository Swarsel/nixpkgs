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
  # testing
  langchain-tests,
  ollama,
  pytest-asyncio,
  pytest-socket,
  pytestCheckHook,
  syrupy,
}:

buildPythonPackage (finalAttrs: {
  pname = "langchain-ollama";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langchain";
    tag = "langchain-ollama==${finalAttrs.version}";
    hash = "sha256-4MbrfHf/ElBFR9cXIx+spQB+xsw2aj94IBJ5hcB6SJ0=";
  };

  strictDeps = true;

  nativeCheckInputs = [
    langchain-tests
    pytestCheckHook
    pytest-asyncio
    pytest-socket
    syrupy
  ];

  __structuredAttrs = true;

  build-system = [
    hatchling
  ];

  dependencies = [
    langchain-core
    ollama
  ];

  disabledTests = [
    # The expected shell can't spawn
    # test_standard_params_model_override - AssertionError: ls_model_name did not reflect the per-call `model` override...ZZ
    "test_standard_params_model_override"
  ];

  enabledTestPaths = [ "tests/unit_tests" ];
  pyproject = true;
  pythonImportsCheck = [ "langchain_ollama" ];
  sourceRoot = "${finalAttrs.src.name}/libs/partners/ollama";

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "langchain-ollama==";
    };
  };

  meta = {
    description = "Integration package connecting Ollama and LangChain";
    homepage = "https://github.com/langchain-ai/langchain/tree/master/libs/partners/ollama";
    changelog = "https://github.com/langchain-ai/langchain/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sarahec ];
  };
})
