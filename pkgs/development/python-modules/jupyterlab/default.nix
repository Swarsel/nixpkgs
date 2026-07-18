{
  lib,
  fetchFromGitHub,
  async-lru,
  buildPythonPackage,
  hatch-jupyter-builder,
  hatchling,
  httpx,
  ipykernel,
  jinja2,
  jupyter-core,
  jupyter-lsp,
  jupyter-server,
  jupyterlab-server,
  nodejs,
  notebook-shim,
  packaging,
  setuptools,
  tornado,
  traitlets,
  yarn-berry_3,
}:

buildPythonPackage (finalAttrs: {
  pname = "jupyterlab";
  version = "4.5.8";

  src = fetchFromGitHub {
    owner = "jupyterlab";
    repo = "jupyterlab";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OtytFZdgGzbQF3icglwRpAn0HhJNyjI6oNS01gfpzkA=";
  };

  nativeBuildInputs = [
    nodejs
    yarn-berry_3.yarnBerryConfigHook
  ];

  preConfigure = ''
    pushd jupyterlab/staging
  '';

  preBuild = ''
    popd
  '';

  # Depends on npm
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    hatch-jupyter-builder
    hatchling
  ];

  dependencies = [
    async-lru
    httpx
    ipykernel
    jinja2
    jupyter-core
    jupyter-lsp
    jupyter-server
    jupyterlab-server
    notebook-shim
    packaging
    setuptools
    tornado
    traitlets
  ];

  makeWrapperArgs = [
    "--set"
    "JUPYTERLAB_DIR"
    "$out/share/jupyter/lab"
  ];

  offlineCache = yarn-berry_3.fetchYarnBerryDeps {
    inherit (finalAttrs) src;
    hash = "sha256-wgqwEl01VinYU5haL1X8Na1lNNcyqCfRaRBze4ypPPo=";
    sourceRoot = "${finalAttrs.src.name}/jupyterlab/staging";
  };

  pyproject = true;
  pythonImportsCheck = [ "jupyterlab" ];

  meta = {
    description = "Jupyter lab environment notebook server extension";
    homepage = "https://jupyter.org/";
    changelog = "https://github.com/jupyterlab/jupyterlab/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    mainProgram = "jupyter-lab";
    teams = [ lib.teams.jupyter ];
  };
})
