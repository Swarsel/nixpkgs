{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  docutils,
  # optional-dependencies
  hatch,
  # build-system
  hatchling,
  jupyter-server,
  jupyterlab-server,
  jupyterlite-core,
  jupytext,
  myst-parser,
  nbformat,
  pydata-sphinx-theme,
  sphinx,
}:

buildPythonPackage (finalAttrs: {
  pname = "jupyterlite-sphinx";
  version = "0.22.1";

  src = fetchFromGitHub {
    owner = "jupyterlite";
    repo = "jupyterlite-sphinx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eww/VyHbAp78Bz2jg43XHmetEDrXEqXK45cnXHElG80=";
  };

  # upstream has no tests
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    hatchling
  ];

  dependencies = [
    docutils
    jupyter-server
    jupyterlab-server
    jupyterlite-core
    finalAttrs.passthru.deps.jupytext
    nbformat
    sphinx
  ];

  optional-dependencies = {
    dev = [
      hatch
    ];

    docs = [
      #jupyterlite-xeus # missing, but not important
      myst-parser
      pydata-sphinx-theme
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "jupyterlite_sphinx"
  ];

  pythonRelaxDeps = [
    "jupyterlite-core"
  ];

  passthru.deps.jupytext = jupytext.overridePythonAttrs (oldAttrs: {
    # FIX: lots of flaky tests
    doCheck = false;
  });

  meta = {
    description = "Sphinx extension that integrates JupyterLite within your Sphinx documentation";
    homepage = "https://github.com/jupyterlite/jupyterlite-sphinx";
    changelog = "https://github.com/jupyterlite/jupyterlite-sphinx/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ eljamm ];
  };
})
