{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  markdown,
  mkdocs,
  mkdocs-test,
  obsidian-callouts,
  obsidian-media,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "mkdocs-obsidian-bridge";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "GooRoo";
    repo = "mkdocs-obsidian-bridge";
    tag = "v${finalAttrs.version}";
    hash = "sha256-362hEIu84dpfo7L+VsK9/AordnByWZUcakO2mByhZaw=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    mkdocs-test
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    markdown
    mkdocs
    obsidian-callouts
    obsidian-media
  ];

  pyproject = true;

  pythonImportsCheck = [
    "mkdocs_obsidian_bridge"
  ];

  meta = {
    description = "Use Obsidian’s syntax for your website with this MkDocs plugin";
    homepage = "https://github.com/GooRoo/mkdocs-obsidian-bridge";

    license = with lib.licenses; [
      bsd3
      cc0
    ];

    maintainers = with lib.maintainers; [ drupol ];
  };
})
