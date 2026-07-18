{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  llm,
  llm-hacker-news,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "llm-hacker-news";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-hacker-news";
    tag = finalAttrs.version;
    hash = "sha256-pywx9TAN/mnGR6Vv6YsPhLO4R5Geagw/bcydQjvTH5s=";
  };

  build-system = [ setuptools ];
  dependencies = [ llm ];
  pyproject = true;
  pythonImportsCheck = [ "llm_hacker_news" ];
  passthru.tests = llm.mkPluginTest llm-hacker-news;

  meta = {
    description = "LLM plugin for pulling content from Hacker News";
    homepage = "https://github.com/simonw/llm-hacker-news";
    changelog = "https://github.com/simonw/llm-hacker-news/releases/tag/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ philiptaron ];
  };
})
