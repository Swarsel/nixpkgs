{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  flit-core,
  # dependencies
  mdformat,
  mdit-py-plugins,
  # tests
  pytestCheckHook,
  ruamel-yaml,
}:

buildPythonPackage (finalAttrs: {
  pname = "mdformat-frontmatter";
  version = "2.0.10";

  src = fetchFromGitHub {
    owner = "butler54";
    repo = "mdformat-frontmatter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-snW9L9vnRHjNchhWZ5sIrn1r4piEYJeKQwib/4rarOo=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ flit-core ];

  dependencies = [
    mdformat
    mdit-py-plugins
    ruamel-yaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "mdformat_frontmatter" ];

  meta = {
    description = "Mdformat plugin to ensure frontmatter is respected";
    homepage = "https://github.com/butler54/mdformat-frontmatter";
    changelog = "https://github.com/butler54/mdformat-frontmatter/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      aldoborrero
      polarmutex
    ];
  };
})
