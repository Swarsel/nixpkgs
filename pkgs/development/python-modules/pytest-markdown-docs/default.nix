{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatchling,
  # dependencies
  markdown-it-py,
  # tests
  mdit-py-plugins,
  pytest,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytest-markdown-docs";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "modal-com";
    repo = "pytest-markdown-docs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7fGuKTHeaMEbsHD9Zje0ODP2FRWSi0WrCZsPwRYP6rg=";
  };

  nativeCheckInputs = [
    mdit-py-plugins
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    markdown-it-py
    pytest
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_markdown_docs" ];

  pythonRelaxDeps = [
    "markdown-it-py"
  ];

  meta = {
    description = "Run pytest on markdown code fence blocks";
    homepage = "https://github.com/modal-com/pytest-markdown-docs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
