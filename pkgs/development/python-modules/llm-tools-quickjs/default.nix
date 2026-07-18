{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  llm,
  llm-echo,
  llm-tools-quickjs,
  pytestCheckHook,
  quickjs,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "llm-tools-quickjs";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-tools-quickjs";
    tag = version;
    hash = "sha256-Si3VcHnRUj8Q/N8pRhltPOM6K64TX9DBH/u4WQxQJjQ=";
  };

  nativeCheckInputs = [
    llm-echo
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    llm
    quickjs
  ];

  pyproject = true;
  pythonImportsCheck = [ "llm_tools_quickjs" ];
  passthru.tests = llm.mkPluginTest llm-tools-quickjs;

  meta = {
    description = "JavaScript execution as a tool for LLM";
    homepage = "https://github.com/simonw/llm-tools-quickjs";
    changelog = "https://github.com/simonw/llm-tools-quickjs/releases/tag/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ philiptaron ];
  };
}
