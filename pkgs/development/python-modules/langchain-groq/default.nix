{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # passthru
  gitUpdater,
  groq,
  # build-system
  hatchling,
  # dependencies
  langchain-core,
  # tests
  langchain-tests,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "langchain-groq";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langchain";
    tag = "langchain-groq==${finalAttrs.version}";
    hash = "sha256-RwwlEL3P/6+Yf1bM5ALGxhUXG0C1XPlf0OQMcft4o4U=";
  };

  nativeCheckInputs = [
    langchain-tests
    pytestCheckHook
  ];

  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    langchain-core
    groq
  ];

  disabledTests = [
    # These tests fail when langchain-core gets ahead of the package
    "test_groq_serialization"
    "test_serdes"
  ];

  enabledTestPaths = [ "tests/unit_tests" ];
  pyproject = true;
  pythonImportsCheck = [ "langchain_groq" ];

  pythonRelaxDeps = [
    # Each component release requests the exact latest core.
    # That prevents us from updating individual components.
    "langchain-core"
    # Requires groq api < 1.0.0, but 1.0.0 is backwards compatible
    "groq"
  ];

  sourceRoot = "${finalAttrs.src.name}/libs/partners/groq";

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "langchain-groq==";
    };
  };

  meta = {
    description = "Integration package connecting Groq and LangChain";
    homepage = "https://github.com/langchain-ai/langchain/tree/master/libs/partners/groq";
    changelog = "https://github.com/langchain-ai/langchain/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      sarahec
    ];
  };
})
