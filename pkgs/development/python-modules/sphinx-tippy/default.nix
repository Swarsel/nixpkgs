{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  flit-core,
  furo,
  jinja2,
  myst-parser,
  requests,
  sphinx,
  sphinxHook,
}:

buildPythonPackage rec {
  pname = "sphinx-tippy";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "sphinx-extensions2";
    repo = "sphinx-tippy";
    tag = "v${version}";
    hash = "sha256-+EXvj8Q6eMu51Gh4hLD6h8I7PDZaeVH+2pZuQUMVH+4=";
  };

  nativeBuildInputs = [
    sphinxHook
    furo
    myst-parser
  ];

  build-system = [
    flit-core
  ];

  dependencies = [
    beautifulsoup4
    jinja2
    requests
    sphinx
  ];

  pyproject = true;

  pythonImportsCheck = [
    "sphinx_tippy"
  ];

  meta = {
    description = "Get rich tool tips in your sphinx documentation";
    homepage = "https://sphinx-tippy.readthedocs.io/en/latest/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ minijackson ];
  };
}
