{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  llm,
  llm-fragments-symbex,
  pytestCheckHook,
  setuptools,
  symbex,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "llm-fragments-symbex";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-fragments-symbex";
    tag = finalAttrs.version;
    hash = "sha256-LECMHv4tGMCY60JU68y2Sfxp97Px7T/RJVhYVDSFCy4=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    llm
    symbex
  ];

  pyproject = true;
  pythonImportsCheck = [ "llm_fragments_symbex" ];
  passthru.tests = llm.mkPluginTest llm-fragments-symbex;

  meta = {
    description = "LLM fragment loader for Python symbols";
    homepage = "https://github.com/simonw/llm-fragments-symbex";
    changelog = "https://github.com/simonw/llm-fragments-symbex/releases/tag/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ philiptaron ];
  };
})
