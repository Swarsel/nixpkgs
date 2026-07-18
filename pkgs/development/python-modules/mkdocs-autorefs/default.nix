{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  markdown,
  markupsafe,
  mkdocs-material,
  pdm-backend,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "mkdocs-autorefs";
  version = "1.4.4";

  src = fetchFromGitHub {
    owner = "mkdocstrings";
    repo = "autorefs";
    tag = version;
    hash = "sha256-kEDnCAqn9musqbY4efUrAHcKc/LAhH1zkLAI9fP/7eg=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'dynamic = ["version"]' 'version = "${version}"'
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ pdm-backend ];

  dependencies = [
    markdown
    markupsafe
    mkdocs-material
  ];

  disabledTestPaths = [
    # Circular dependencies
    "tests/test_api.py"
  ];

  disabledTests = [
    # missing pymdownx
    "test_reference_implicit_with_code_inlinehilite_plain"
    "test_reference_implicit_with_code_inlinehilite_python"
  ];

  pyproject = true;
  pythonImportsCheck = [ "mkdocs_autorefs" ];

  meta = {
    description = "Automatically link across pages in MkDocs";
    homepage = "https://github.com/mkdocstrings/autorefs/";
    changelog = "https://github.com/mkdocstrings/autorefs/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ fab ];
  };
}
