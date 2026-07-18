{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  llm,
  llm-fragments-github,
  setuptools,
}:

buildPythonPackage rec {
  pname = "llm-fragments-github";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-fragments-github";
    tag = version;
    hash = "sha256-7i1WRix5AAEG5EXJqtaU+QY56aL0SePdqz84z+C+iYM=";
  };

  build-system = [ setuptools ];
  dependencies = [ llm ];
  pyproject = true;
  pythonImportsCheck = [ "llm_fragments_github" ];
  passthru.tests = llm.mkPluginTest llm-fragments-github;

  meta = {
    description = "Load GitHub repository contents as LLM fragments";
    homepage = "https://github.com/simonw/llm-fragments-github";
    changelog = "https://github.com/simonw/llm-fragments-github/releases/tag/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ philiptaron ];
  };
}
