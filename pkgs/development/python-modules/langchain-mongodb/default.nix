{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # test
  freezegun,
  # passthru
  gitUpdater,
  # build-system
  hatchling,
  httpx,
  # dependencies
  langchain,
  langchain-classic,
  langchain-community,
  langchain-core,
  langchain-ollama,
  langchain-openai,
  langchain-tests,
  langchain-text-splitters,
  lark,
  mongomock,
  numpy,
  pymongo,
  pymongo-search-utils,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
  pythonAtLeast,
  syrupy,
}:

buildPythonPackage (finalAttrs: {
  pname = "langchain-mongodb";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langchain-mongodb";
    tag = "libs/langchain-mongodb/v${finalAttrs.version}";
    hash = "sha256-dO0dASjyNMxnbxZ/ry8lcJxedPdrv6coYiTjOcaT8/0=";
  };

  nativeCheckInputs = [
    freezegun
    httpx
    langchain-community
    langchain-ollama
    langchain-openai
    langchain-tests
    lark
    mongomock
    pytest-asyncio
    pytestCheckHook
    pytest-mock
    syrupy
  ];

  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    langchain
    langchain-classic
    langchain-core
    langchain-text-splitters
    numpy
    pymongo
    pymongo-search-utils
  ];

  disabledTestPaths = [
    # Expects a MongoDB cluster and are very slow
    "tests/unit_tests/test_index.py"
  ];

  enabledTestPaths = [ "tests/unit_tests" ];
  pyproject = true;

  pytestFlags = [
    # DeprecationWarning: 'asyncio.get_event_loop_policy' is deprecated
    "-Wignore::DeprecationWarning"
    "-Wignore::PendingDeprecationWarning"
  ]
  ++ lib.optionals (pythonAtLeast "3.14") [
    # UserWarning: Core Pydantic V1 functionality isn't compatible with Python 3.14
    "-Wignore::UserWarning"
  ];

  pythonImportsCheck = [ "langchain_mongodb" ];
  sourceRoot = "${finalAttrs.src.name}/libs/langchain-mongodb";

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "libs/langchain-mongodb/v";
    };
  };

  meta = {
    description = "Integration package connecting MongoDB and LangChain";
    homepage = "https://github.com/langchain-ai/langchain-mongodb";
    changelog = "https://github.com/langchain-ai/langchain-mongodb/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      natsukium
      sarahec
    ];
  };
})
