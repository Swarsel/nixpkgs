{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  llm,
  llm-echo,
  llm-tools-simpleeval,
  pytestCheckHook,
  setuptools,
  simpleeval,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "llm-tools-simpleeval";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-tools-simpleeval";
    tag = version;
    hash = "sha256-IOmYu7zoim7Co/xIm5VLaGkCPI0o+2Nb2Pu3U2fH0BU=";
  };

  nativeCheckInputs = [
    llm-echo
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    llm
    simpleeval
  ];

  pyproject = true;
  pythonImportsCheck = [ "llm_tools_simpleeval" ];
  passthru.tests = llm.mkPluginTest llm-tools-simpleeval;

  meta = {
    description = "Make simple_eval available as an LLM tool";
    homepage = "https://github.com/simonw/llm-tools-simpleeval";
    changelog = "https://github.com/simonw/llm-tools-simpleeval/releases/tag/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ philiptaron ];
  };
}
