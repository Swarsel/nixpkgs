{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
  regex,
  typer,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-obfuscator";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "davidteather";
    repo = "python-obfuscator";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ddFmlNBtITMPJszLjD2FNjSFF8TrawOv0q7iB3EIdAY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    regex
    typer
  ];

  pyproject = true;
  pythonImportsCheck = [ "python_obfuscator" ];
  pythonRelaxDeps = [ "typer" ];

  meta = {
    description = "Module to obfuscate code";
    homepage = "https://github.com/davidteather/python-obfuscator";
    changelog = "https://github.com/davidteather/python-obfuscator/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
