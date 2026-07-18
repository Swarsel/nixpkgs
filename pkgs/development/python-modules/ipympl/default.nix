{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatch-jupyter-builder,
  hatch-nodejs-version,
  hatchling,
  # tests
  importlib-metadata,
  # dependencies
  ipython,
  ipywidgets,
  jupyterlab,
  matplotlib,
  nbval,
  # frontend
  nodejs,
  numpy,
  pillow,
  pytestCheckHook,
  traitlets,
  yarn-berry_3,
}:

buildPythonPackage (finalAttrs: {
  pname = "ipympl";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "matplotlib";
    repo = "ipympl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IJ7tLUE0Ac4biQc9b87adgDcD8pa9XH1bo8rzDl9DCY=";
  };

  nativeBuildInputs = [
    nodejs
    yarn-berry_3.yarnBerryConfigHook
  ];

  nativeCheckInputs = [
    importlib-metadata
    nbval
    pytestCheckHook
  ];

  build-system = [
    hatch-jupyter-builder
    hatch-nodejs-version
    hatchling
    jupyterlab
  ];

  dependencies = [
    ipython
    ipywidgets
    matplotlib
    numpy
    pillow
    traitlets
  ];

  pyproject = true;

  pythonImportsCheck = [
    "ipympl"
    "ipympl.backend_nbagg"
  ];

  yarnOfflineCache = yarn-berry_3.fetchYarnBerryDeps {
    inherit (finalAttrs) src;
    hash = "sha256-tdfrAf2BSz9n83ctWqRxDHZnhnfhKA3BFNhXVr9wvLY=";
  };

  meta = {
    description = "Matplotlib Jupyter Extension";
    homepage = "https://github.com/matplotlib/jupyter-matplotlib";
    changelog = "https://github.com/matplotlib/ipympl/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      jluttine
    ];
  };
})
