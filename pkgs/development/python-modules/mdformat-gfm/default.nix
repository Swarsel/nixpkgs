{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  flit-core,
  # dependencies
  markdown-it-py,
  mdformat,
  mdit-py-plugins,
  # tests
  pytestCheckHook,
  wcwidth,
}:

buildPythonPackage (finalAttrs: {
  pname = "mdformat-gfm";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "hukkin";
    repo = "mdformat-gfm";
    tag = finalAttrs.version;
    hash = "sha256-Vijt5P3KRL4jkU8AI2lAsJkvFne/l3utUkjHUs8PQHI=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    flit-core
  ];

  dependencies = [
    markdown-it-py
    mdformat
    mdit-py-plugins
    wcwidth
  ];

  pyproject = true;
  pythonImportsCheck = [ "mdformat_gfm" ];

  meta = {
    description = "Mdformat plugin for GitHub Flavored Markdown compatibility";
    homepage = "https://github.com/hukkin/mdformat-gfm";
    changelog = "https://github.com/hukkin/mdformat-gfm/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      aldoborrero
      polarmutex
    ];
  };
})
