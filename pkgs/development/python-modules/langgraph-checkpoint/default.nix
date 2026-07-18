{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # testing
  dataclasses-json,
  # passthru
  gitUpdater,
  # build system
  hatchling,
  # dependencies
  langchain-core,
  msgpack,
  numpy,
  ormsgpack,
  pandas,
  pycryptodome,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
  redis,
}:

buildPythonPackage (finalAttrs: {
  pname = "langgraph-checkpoint";
  version = "4.1.1";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langgraph";
    tag = "checkpoint==${finalAttrs.version}";
    hash = "sha256-P4SbQK6lFG572WKxisnNn/ZiHcMYBBM/vcBB9N6xpfo=";
  };

  propagatedBuildInputs = [ msgpack ];

  nativeCheckInputs = [
    dataclasses-json
    numpy
    pandas
    pycryptodome
    pytest-asyncio
    pytest-mock
    pytestCheckHook
    redis
  ];

  build-system = [ hatchling ];

  dependencies = [
    langchain-core
    ormsgpack
  ];

  pyproject = true;
  pythonImportsCheck = [ "langgraph.checkpoint" ];
  sourceRoot = "${finalAttrs.src.name}/libs/checkpoint";

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "checkpoint==";
    };
  };

  meta = {
    description = "Library with base interfaces for LangGraph checkpoint savers";
    homepage = "https://github.com/langchain-ai/langgraph/tree/main/libs/checkpoint";
    changelog = "https://github.com/langchain-ai/langgraph/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      sarahec
    ];
  };
})
