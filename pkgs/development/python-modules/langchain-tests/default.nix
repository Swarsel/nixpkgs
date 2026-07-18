{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # passthru
  gitUpdater,
  # build-system
  hatchling,
  # dependencies
  httpx,
  langchain-core,
  numpy,
  pytest-asyncio,
  # tests
  pytest-benchmark,
  pytest-recording,
  pytest-socket,
  # buildInputs
  pytestCheckHook,
  syrupy,
  vcrpy,
}:

buildPythonPackage (finalAttrs: {
  pname = "langchain-tests";
  version = "1.1.9";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langchain";
    tag = "langchain-tests==${finalAttrs.version}";
    hash = "sha256-GbOasYdPGqk1WJeoqL8DYd1Qizvhjeq8Dc+RgE4iBaA=";
  };

  nativeBuildInputs = [
    pytestCheckHook
  ];

  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    httpx
    langchain-core
    numpy
    pytest-asyncio
    pytest-benchmark
    pytest-recording
    pytest-socket
    syrupy
    vcrpy
  ];

  disabledTestMarks = [
    "benchmark"
  ];

  pyproject = true;
  pythonImportsCheck = [ "langchain_tests" ];

  pythonRelaxDeps = [
    "pytest"
    "syrupy"
    "vcrpy"
  ];

  pythonRemoveDeps = [
    "pytest-benchmark"
    "pytest-codspeed"
  ];

  sourceRoot = "${finalAttrs.src.name}/libs/standard-tests";

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "langchain-tests==";
    };
  };

  meta = {
    description = "Build context-aware reasoning applications";
    homepage = "https://github.com/langchain-ai/langchain";
    changelog = "https://github.com/langchain-ai/langchain/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      natsukium
      sarahec
    ];
  };
})
