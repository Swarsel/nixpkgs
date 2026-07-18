{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  llm,
  llm-templates-github,
  setuptools,
}:

buildPythonPackage rec {
  pname = "llm-templates-github";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-templates-github";
    tag = version;
    hash = "sha256-SFXrvpKrvfIP0JmXQt6OZ52kne4AEtiggbshyac9XQc=";
  };

  build-system = [ setuptools ];
  dependencies = [ llm ];
  pyproject = true;
  pythonImportsCheck = [ "llm_templates_github" ];
  passthru.tests = llm.mkPluginTest llm-templates-github;

  meta = {
    description = "Load LLM templates from GitHub repositories";
    homepage = "https://github.com/simonw/llm-templates-github";
    changelog = "https://github.com/simonw/llm-templates-github/releases/tag/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ philiptaron ];
  };
}
