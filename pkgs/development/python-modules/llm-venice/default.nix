{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  llm,
  llm-venice,
  setuptools,
}:

buildPythonPackage rec {
  pname = "llm-venice";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "ar-jan";
    repo = "llm-venice";
    tag = version;
    hash = "sha256-jshOfbZUccmK6sRCDTzkE7tOKX2ILue93Jp2GFoGTxY=";
  };

  # Reaches out to the real API
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ llm ];
  pyproject = true;
  pythonImportsCheck = [ "llm_venice" ];
  passthru.tests = llm.mkPluginTest llm-venice;

  meta = {
    description = "LLM plugin to access models available via the Venice API";
    homepage = "https://github.com/ar-jan/llm-venice";
    changelog = "https://github.com/ar-jan/llm-venice/releases/tag/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ philiptaron ];
  };
}
