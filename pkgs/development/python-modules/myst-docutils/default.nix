{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  defusedxml,
  docutils,
  flit-core,
  jinja2,
  markdown-it-py,
  mdit-py-plugins,
  pytest-param-files,
  pytest-regressions,
  pytestCheckHook,
  pyyaml,
  sphinx,
  sphinx-pytest,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "myst-docutils";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "executablebooks";
    repo = "MyST-Parser";
    tag = "v${version}";
    hash = "sha256-0lGejdGVVvZar3sPBbvThXzJML7PcR5+shyDHTTtVEY=";
  };

  nativeCheckInputs = [
    beautifulsoup4
    defusedxml
    pytest-param-files
    pytest-regressions
    pytestCheckHook
    sphinx-pytest
  ];

  build-system = [ flit-core ];

  dependencies = [
    docutils
    jinja2
    markdown-it-py
    mdit-py-plugins
    pyyaml
    sphinx
    typing-extensions
  ];

  disabledTestPaths = [
    # Assertion errors
    "tests/test_sphinx/"
  ];

  disabledTests = [
    # Tests require linkify
    "test_cmdline"
    "test_extended_syntaxes"
    # sphinx compat
    "test_sphinx_directives"
  ];

  pyproject = true;
  pythonImportsCheck = [ "myst_parser" ];

  meta = {
    description = "Extended commonmark compliant parser, with bridges to docutils/sphinx";
    homepage = "https://github.com/executablebooks/MyST-Parser";
    changelog = "https://github.com/executablebooks/MyST-Parser/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
  };
}
