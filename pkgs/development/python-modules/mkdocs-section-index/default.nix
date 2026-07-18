{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  mechanicalsoup,
  mkdocs,
  mkdocs-material,
  pytest-golden,
  pytestCheckHook,
  testfixtures,
}:

buildPythonPackage (finalAttrs: {
  pname = "mkdocs-section-index";
  version = "0.3.10";

  src = fetchFromGitHub {
    owner = "oprypin";
    repo = "mkdocs-section-index";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cw/a17xliK68vStC20f+IHI3nQl1/s/lIIj1tyQJti0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    mechanicalsoup
    testfixtures
    pytest-golden
    mkdocs-material
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    mkdocs
  ];

  pyproject = true;

  pythonImportsCheck = [
    "mkdocs_section_index"
  ];

  meta = {
    description = "MkDocs plugin to allow clickable sections that lead to an index page";
    homepage = "https://github.com/oprypin/mkdocs-section-index";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ drupol ];
  };
})
