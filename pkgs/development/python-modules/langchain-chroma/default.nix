{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  chromadb,
  # passthru
  gitUpdater,
  # build-system
  hatchling,
  langchain-core,
  # tests
  langchain-tests,
  numpy,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "langchain-chroma";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langchain";
    tag = "langchain-chroma==${version}";
    hash = "sha256-WyW5QNLzbqI+kXIVCDyXLyqpShNOSk7tyBTdNoXGQZ0=";
  };

  nativeCheckInputs = [
    langchain-tests
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    chromadb
    langchain-core
    numpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "langchain_chroma" ];

  pythonRelaxDeps = [
    # Each component release requests the exact latest core.
    # That prevents us from updating individual components.
    "langchain-core"
    "numpy"
  ];

  sourceRoot = "${src.name}/libs/partners/chroma";

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "langchain-chroma==";
    };
  };

  meta = {
    description = "Integration package connecting Chroma and LangChain";
    homepage = "https://github.com/langchain-ai/langchain/tree/master/libs/partners/chroma";
    changelog = "https://github.com/langchain-ai/langchain/releases/tag/${src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      natsukium
      sarahec
    ];
  };
}
