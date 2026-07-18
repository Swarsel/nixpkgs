{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  git,
  gitMinimal,
  hatch-jupyter-builder,
  hatch-nodejs-version,
  hatchling,
  jupyter-server,
  jupyterlab,
  nbdime,
  nbformat,
  nodejs,
  packaging,
  pexpect,
  pytest-asyncio,
  pytest-jupyter,
  pytest-tornasync,
  pytestCheckHook,
  traitlets,
  writableTmpDirAsHomeHook,
  yarn-berry_3,
}:

buildPythonPackage rec {
  pname = "jupyterlab-git";
  version = "0.52.0";

  src = fetchFromGitHub {
    owner = "jupyterlab";
    repo = "jupyterlab-git";
    tag = "v${version}";
    hash = "sha256-BMzn+134hSYUFrDF+4+Bs81hzSURP9VNX4D9x2UuPMQ=";
  };

  nativeBuildInputs = [
    nodejs
    yarn-berry_3.yarnBerryConfigHook
  ];

  propagatedBuildInputs = [ git ];

  nativeCheckInputs = [
    gitMinimal
    pytest-asyncio
    pytest-jupyter
    pytest-tornasync
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    hatch-jupyter-builder
    hatch-nodejs-version
    hatchling
    jupyterlab
  ];

  dependencies = [
    jupyter-server
    nbdime
    nbformat
    packaging
    pexpect
    traitlets
  ];

  disabledTestPaths = [
    "jupyterlab_git/tests/test_handlers.py"
  ];

  disabledTests = [
    "test_Git_get_nbdiff_file"
    "test_Git_get_nbdiff_dict"
  ];

  offlineCache = yarn-berry_3.fetchYarnBerryDeps {
    inherit src;
    hash = "sha256-3pVc4xz5ilamCg97wdaLQliBHeSr3mPYwhgnz/lvfj0=";
  };

  pyproject = true;
  pythonImportsCheck = [ "jupyterlab_git" ];

  meta = {
    description = "Jupyter lab extension for version control with Git";
    homepage = "https://github.com/jupyterlab/jupyterlab-git";
    changelog = "https://github.com/jupyterlab/jupyterlab-git/blob/${src.tag}/CHANGELOG.md";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ chiroptical ];
  };
}
