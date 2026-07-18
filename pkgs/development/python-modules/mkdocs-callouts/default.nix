{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mkdocs,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "mkdocs-callouts";
  version = "1.16.1";

  src = fetchFromGitHub {
    owner = "sondregronas";
    repo = "mkdocs-callouts";
    tag = "v${finalAttrs.version}";
    hash = "sha256-I7KHZgUV67Ff9Nt1z1LVjia9eQ5V+7y24ZepkpooT2w=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  dependencies = [
    mkdocs
  ];

  pyproject = true;

  pythonImportsCheck = [
    "mkdocs_callouts"
  ];

  meta = {
    description = "A simple MkDocs plugin that converts Obsidian callout blocks to mkdocs supported Admonitions";
    homepage = "https://github.com/sondregronas/mkdocs-callouts";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ drupol ];
  };
})
