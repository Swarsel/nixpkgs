{
  lib,
  fetchFromGitHub,
  # tests
  beautifulsoup4,
  buildPythonPackage,
  defusedxml,
  # dependencies
  docutils,
  # build-system
  flit-core,
  jinja2,
  markdown-it-py,
  mdit-py-plugins,
  pytest-param-files,
  pytest-regressions,
  pytestCheckHook,
  pythonOlder,
  pyyaml,
  sphinx,
  sphinx-pytest,
  typing-extensions,
}:
buildPythonPackage (finalAttrs: {
  pname = "myst-parser";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "executablebooks";
    repo = "myst-parser";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0lGejdGVVvZar3sPBbvThXzJML7PcR5+shyDHTTtVEY=";
  };

  nativeCheckInputs = [
    beautifulsoup4
    defusedxml
    pytest-param-files
    pytest-regressions
    pytestCheckHook
    sphinx-pytest
  ]
  ++ markdown-it-py.optional-dependencies.linkify;

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

  disabled = pythonOlder "3.11";

  disabledTestPaths = [
    # outdated sphinx fixtures
    "tests/test_renderers/test_fixtures_sphinx.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "myst_parser" ];

  pythonRelaxDeps = [
    "markdown-it-py"
  ];

  meta = {
    description = "Sphinx and Docutils extension to parse MyST";
    homepage = "https://myst-parser.readthedocs.io/";
    changelog = "https://raw.githubusercontent.com/executablebooks/MyST-Parser/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ loicreynier ];
  };
})
