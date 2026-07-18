{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
  importlib-metadata,
  ipykernel,
  ipython,
  jupyter-cache,
  myst-parser,
  nbclient,
  nbformat,
  pyyaml,
  sphinx,
  sphinx-togglebutton,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "myst-nb";
  version = "1.3.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-3zzUaA9Rpa9nP9RrOLVivjVZrvFHXpBu0PLmbkWHzks=";
    pname = "myst_nb";
  };

  nativeBuildInputs = [ flit-core ];

  propagatedBuildInputs = [
    importlib-metadata
    ipython
    jupyter-cache
    nbclient
    myst-parser
    nbformat
    pyyaml
    sphinx
    sphinx-togglebutton
    typing-extensions
    ipykernel
  ];

  pyproject = true;

  pythonImportsCheck = [
    "myst_nb"
    "myst_nb.sphinx_ext"
  ];

  meta = {
    description = "Jupyter Notebook Sphinx reader built on top of the MyST markdown parser";
    homepage = "https://github.com/executablebooks/MyST-NB";
    changelog = "https://github.com/executablebooks/MyST-NB/raw/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
