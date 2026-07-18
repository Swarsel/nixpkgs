{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  llm,
  llm-deepseek,
  setuptools,
}:

buildPythonPackage rec {
  pname = "llm-deepseek";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "abrasumente233";
    repo = "llm-deepseek";
    tag = version;
    hash = "sha256-yrNvIGnU9Q/0H786DsM0wGEwfxZYIk8IXhqC4mWaQAA=";
  };

  build-system = [ setuptools ];
  dependencies = [ llm ];
  pyproject = true;
  pythonImportsCheck = [ "llm_deepseek" ];
  passthru.tests = llm.mkPluginTest llm-deepseek;

  meta = {
    description = "LLM plugin providing access to Deepseek models.";
    homepage = "https://github.com/abrasumente233/llm-deepseek";
    changelog = "https://github.com/abrasumente233/llm-deepseek/releases/tag/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ philiptaron ];
  };
}
