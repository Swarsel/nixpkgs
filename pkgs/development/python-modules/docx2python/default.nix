{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lxml,
  paragraphs,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  types-lxml,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "docx2python";
  version = "3.6.2";

  src = fetchFromGitHub {
    owner = "ShayHill";
    repo = "docx2python";
    tag = finalAttrs.version;
    hash = "sha256-1/v8slL7EYwXM8ybcJKIdjLBKNBxHgdF4gQHDYyJg6w=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    lxml
    paragraphs
    types-lxml
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "docx2python" ];

  meta = {
    description = "Extract docx headers, footers, (formatted) text, footnotes, endnotes, properties, and images";
    homepage = "https://github.com/ShayHill/docx2python";
    changelog = "https://github.com/ShayHill/docx2python/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
