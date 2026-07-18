{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  callPackages,
  nix-update-script,
  pcpp,
  platformdirs,
  poetry-core,
  pydantic,
  pydantic-settings,
  pyparsing,
  pythonOlder,
  pyyaml,
  tree-sitter,
  tree-sitter-grammars,
  versionCheckHook,
}:
buildPythonPackage (finalAttrs: {
  pname = "keymap-drawer";
  version = "0.23.0";

  src = fetchFromGitHub {
    owner = "caksoylar";
    repo = "keymap-drawer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yrZidTATnOPacAfdk0gFIgH/3MaZqVOjmzkWNnMa01s=";
  };

  nativeCheckInputs = [
    versionCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    pcpp
    platformdirs
    pydantic
    pydantic-settings
    pyparsing
    pyyaml
    tree-sitter
    tree-sitter-grammars.tree-sitter-devicetree
  ];

  disabled = pythonOlder "3.12";
  pyproject = true;
  pythonImportsCheck = [ "keymap_drawer" ];

  pythonRelaxDeps = [
    "tree-sitter-devicetree"
  ];

  passthru.tests = callPackages ./tests {
    keymap-drawer = finalAttrs.finalPackage;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Module and CLI tool to help parse and draw keyboard layouts";
    homepage = "https://github.com/caksoylar/keymap-drawer";
    changelog = "https://github.com/caksoylar/keymap-drawer/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      MattSturgeon
    ];

    mainProgram = "keymap";
  };
})
