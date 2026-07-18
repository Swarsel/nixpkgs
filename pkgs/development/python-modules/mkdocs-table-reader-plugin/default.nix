{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mkdocs,
  mkdocs-macros-plugin,
  openpyxl,
  pandas,
  pytestCheckHook,
  pyyaml,
  setuptools,
  tabulate,
}:

buildPythonPackage rec {
  pname = "mkdocs-table-reader-plugin";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "timvink";
    repo = "mkdocs-table-reader-plugin";
    tag = "v${version}";
    hash = "sha256-XyMz0CeLQderzzz/Z3H6rja619wPzx42X3jz30wt6a8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    openpyxl
    mkdocs-macros-plugin
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    mkdocs
    pandas
    tabulate
    pyyaml
  ];

  disabledTests = [
    # fails with non zero exit code without printing stdout/stderr of `mkdocs build` -> cause unknown
    "test_compatibility_markdownextradata"
    "test_macros_jinja2_syntax"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "mkdocs_table_reader_plugin"
  ];

  meta = {
    description = "MkDocs plugin that enables a markdown tag like {{ read_csv('table.csv') }} to directly insert various table formats into a page";
    homepage = "https://github.com/timvink/mkdocs-table-reader-plugin";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ marcel ];
  };
}
