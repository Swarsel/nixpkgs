{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  commonmark,
  flit-core,
  ipykernel,
  jupyter-sphinx,
  linkify-it-py,
  markdown,
  mdit-py-plugins,
  mdurl,
  mistletoe,
  mistune,
  myst-parser,
  panflute,
  pytest-regressions,
  pytestCheckHook,
  pyyaml,
  sphinx,
  sphinx-book-theme,
  sphinx-copybutton,
  sphinx-design,
}:

buildPythonPackage rec {
  pname = "markdown-it-py";
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "executablebooks";
    repo = "markdown-it-py";
    tag = "v${version}";
    hash = "sha256-92J9cMit2zwyjoE8G1YpwDxj+wiApQW2eUHxUOUt3as=";
  };

  doCheck = !stdenv.hostPlatform.isi686;

  nativeCheckInputs = [
    pytest-regressions
    pytestCheckHook
  ]
  ++ optional-dependencies.linkify;

  # disable and remove benchmark tests
  preCheck = ''
    rm -r benchmarking
  '';

  build-system = [
    flit-core
  ];

  dependencies = [ mdurl ];

  optional-dependencies = {
    compare = [
      commonmark
      markdown
      mistletoe
      mistune
      panflute
      # FIXME package markdown-it-pyrs
    ];

    linkify = [ linkify-it-py ];
    plugins = [ mdit-py-plugins ];

    rtd = [
      mdit-py-plugins
      myst-parser
      pyyaml
      sphinx
      sphinx-copybutton
      sphinx-design
      sphinx-book-theme
      jupyter-sphinx
      ipykernel
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "markdown_it" ];
  # fix downstrem usage of markdown-it-py[linkify]
  pythonRelaxDeps = [ "linkify-it-py" ];

  meta = {
    description = "Markdown parser in Python";
    homepage = "https://markdown-it-py.readthedocs.io/";
    changelog = "https://github.com/executablebooks/markdown-it-py/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "markdown-it";
  };
}
