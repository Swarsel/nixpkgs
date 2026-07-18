{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  filetype,
  # tests
  freezegun,
  # passthru
  gitUpdater,
  google-api-core,
  google-auth,
  google-genai,
  # build-system
  hatchling,
  langchain-core,
  langchain-tests,
  numpy,
  pydantic,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
  syrupy,
}:

buildPythonPackage (finalAttrs: {
  pname = "langchain-google-genai";
  version = "4.2.7";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langchain-google";
    tag = "libs/genai/v${finalAttrs.version}";
    hash = "sha256-pfjnXbUr8lkztcNZ8JImi+NiMF0DHOS3qtFsv5fKDiU=";
  };

  nativeCheckInputs = [
    freezegun
    langchain-tests
    numpy
    pytest-asyncio
    pytest-mock
    pytestCheckHook
    syrupy
  ];

  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    filetype
    google-api-core
    google-auth
    google-genai
    langchain-core
    pydantic
  ];

  disabledTestPaths = [
    # AssertionError: assert {'google_maps...s': None, ...} == {'google_maps...a'...
    # https://github.com/langchain-ai/langchain-google/issues/1791
    "tests/unit_tests/test_chat_models.py::test_response_to_result_grounding_metadata"
  ];

  disabledTests = [
    # Fails when langchain-core gets ahead of this package
    "test_serdes"
    "test_serialize"
    # pydantic_core._pydantic_core.ValidationError: 1 validation error for GenerateContentResponse
    # extra inputs are not permitted
    "test_grounding_metadata_to_citations_conversion"
  ];

  enabledTestPaths = [ "tests/unit_tests" ];
  pyproject = true;
  pythonImportsCheck = [ "langchain_google_genai" ];
  sourceRoot = "${finalAttrs.src.name}/libs/genai";

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "libs/genai/v";
    };
  };

  meta = {
    description = "LangChain integrations for Google Gemini";
    homepage = "https://github.com/langchain-ai/langchain-google/tree/main/libs/genai";
    changelog = "https://github.com/langchain-ai/langchain-google/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      eu90h
      sarahec
    ];
  };
})
