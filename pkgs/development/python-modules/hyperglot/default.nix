{
  lib,
  fetchFromGitHub,
  buildPythonApplication,
  click,
  colorlog,
  fonttools,
  nix-update-script,
  packaging,
  pytestCheckHook,
  pyyaml,
  setuptools,
  uharfbuzz,
}:
buildPythonApplication rec {
  pname = "hyperglot";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "rosettatype";
    repo = "hyperglot";
    tag = version;
    hash = "sha256-fiiDYggMBwd7nTHeQLWnSc3BNDyU+JUgAIk8pHLntUY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    click
    fonttools
    uharfbuzz
    pyyaml
    colorlog
    packaging
  ];

  pyproject = true;
  pythonImportsCheck = [ "hyperglot" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Database and tools for detecting language support in fonts";
    homepage = "https://hyperglot.rosettatype.com";
    changelog = "https://github.com/rosettatype/hyperglot/blob/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ imatpot ];
    mainProgram = "hyperglot";
  };
}
