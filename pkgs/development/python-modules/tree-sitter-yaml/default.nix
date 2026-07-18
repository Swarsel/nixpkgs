{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  pytestCheckHook,
  rustPlatform,
  rustc,
  setuptools,
  tree-sitter,
}:

buildPythonPackage rec {
  pname = "tree-sitter-yaml";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "tree-sitter-grammars";
    repo = "tree-sitter-yaml";
    tag = "v${version}";
    hash = "sha256-BX6TOfAZLW+0h2TNsgsLC9K2lfirraCWlBN2vCKiXQ4=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    tree-sitter
  ];

  build-system = [
    cargo
    rustPlatform.cargoSetupHook
    rustc
    setuptools
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-mrLuGmauboKHHk0zADPXpwgZfc83syXk0jmD93Y9Jq4=";
  };

  optional-dependencies = {
    core = [
      tree-sitter
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "tree_sitter_yaml" ];

  meta = {
    description = "YAML grammar for tree-sitter";
    homepage = "https://github.com/tree-sitter-grammars/tree-sitter-yaml";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ yzx9 ];
  };
}
