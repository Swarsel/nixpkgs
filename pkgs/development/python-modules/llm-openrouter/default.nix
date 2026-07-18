{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  inline-snapshot,
  llm,
  llm-openrouter,
  openai,
  pytest-recording,
  pytestCheckHook,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "llm-openrouter";
  version = "0.6";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-openrouter";
    tag = version;
    hash = "sha256-xlSeFWlamt3my20gANdZellaUHuDmjFClsQwrv/bq18=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    inline-snapshot
    pytest-recording
    writableTmpDirAsHomeHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    httpx
    llm
    openai
  ];

  pyproject = true;
  pythonImportsCheck = [ "llm_openrouter" ];
  passthru.tests = llm.mkPluginTest llm-openrouter;

  meta = {
    description = "LLM plugin for models hosted by OpenRouter";
    homepage = "https://github.com/simonw/llm-openrouter";
    changelog = "https://github.com/simonw/llm-openrouter/releases/tag/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      arcuru
      philiptaron
    ];
  };
}
