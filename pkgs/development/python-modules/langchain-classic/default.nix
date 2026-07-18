{
  lib,
  fetchFromGitHub,
  # tests
  blockbuster,
  buildPythonPackage,
  cffi,
  freezegun,
  # update
  gitUpdater,
  # build-system
  hatchling,
  # dependencies
  langchain-core,
  langchain-openai,
  langchain-tests,
  langchain-text-splitters,
  langsmith,
  lark,
  numpy,
  packaging,
  pandas,
  pydantic,
  pytest-asyncio,
  pytest-dotenv,
  pytest-mock,
  pytest-socket,
  pytest-xdist,
  pytest8_3CheckHook,
  pyyaml,
  requests,
  requests-mock,
  responses,
  sqlalchemy,
  syrupy,
  toml,
}:

buildPythonPackage (finalAttrs: {
  pname = "langchain-classic";
  version = "1.0.8";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langchain";
    tag = "langchain-classic==${finalAttrs.version}";
    hash = "sha256-Xskg6bPmRv7iLjppUF11rqmHg2YJWETVT1EMhzK7Svo=";
  };

  nativeCheckInputs = [
    blockbuster
    cffi
    freezegun
    langchain-core
    langchain-openai
    langchain-tests
    langchain-text-splitters
    lark
    numpy
    packaging
    pandas
    pytest-asyncio
    pytest-dotenv
    pytest-mock
    pytest-socket
    pytest-xdist
    pytest8_3CheckHook
    requests-mock
    responses
    syrupy
    toml
  ];

  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    langchain-core
    langchain-text-splitters
    langsmith
    pydantic
    pyyaml
    requests
    sqlalchemy
  ];

  disabledTests = [
    # Network access (web.example.com)
    "test_socket_disabled"
  ];

  enabledTestPaths = [
    # integration_tests require network access, database access and require `OPENAI_API_KEY`, etc.
    "tests/unit_tests"
  ];

  pyproject = true;
  pythonImportsCheck = [ "langchain_classic" ];
  sourceRoot = "${finalAttrs.src.name}/libs/langchain";

  # Bulk updater selects wrong tag
  passthru = {
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "langchain-classic==";
    };
  };

  meta = {
    description = "Classic (0.x) compatibility layer for LangChain";
    homepage = "https://github.com/langchain-ai/langchain/tree/master/libs/langchain";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sarahec ];
  };
})
