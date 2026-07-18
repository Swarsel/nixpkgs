{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  mkdocs,
  pytest-golden,
  pytestCheckHook,
  testfixtures,
}:

buildPythonPackage rec {
  pname = "mkdocs-literate-nav";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "oprypin";
    repo = "mkdocs-literate-nav";
    tag = "v${version}";
    hash = "sha256-WP8VqiD/Kqswh1TWhSBsNfxn3gxKlRlg6RvGayAdQto=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    testfixtures
    pytest-golden
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    mkdocs
  ];

  pyproject = true;

  pythonImportsCheck = [
    "mkdocs_literate_nav"
  ];

  meta = {
    description = "MkDocs plugin to specify the navigation in Markdown instead of YAML";
    homepage = "https://github.com/oprypin/mkdocs-literate-nav";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ drupol ];
  };
}
