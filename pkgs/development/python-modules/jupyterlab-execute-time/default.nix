{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-jupyter-builder,
  # build-system
  hatchling,
  # dependencies
  jupyter-packaging,
  # build inputs
  jupyterlab,
  nodejs,
  writableTmpDirAsHomeHook,
  yarn-berry_3,
}:

buildPythonPackage rec {
  pname = "jupyterlab-execute-time";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "deshaw";
    repo = "jupyterlab-execute-time";
    rev = "v${version}";
    hash = "sha256-1eNv6yTyorg64PXQm68eqp56Ig0eUbhPWluI/s4oijE=";
  };

  # Fix version requirements and replace jupyterlab's pinned yarn (jlpm) with yarn
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "jupyterlab~=4.0.0" "jupyterlab"
    substituteInPlace pyproject.toml package.json \
      --replace-fail 'jlpm' 'yarn'
  '';

  nativeBuildInputs = [
    jupyterlab
    nodejs
    writableTmpDirAsHomeHook
    yarn-berry_3
    yarn-berry_3.yarnBerryConfigHook
  ];

  build-system = [
    hatchling
    hatch-jupyter-builder
  ];

  dependencies = [
    jupyterlab
    jupyter-packaging
  ];

  offlineCache = yarn-berry_3.fetchYarnBerryDeps {
    hash = "sha256-aCuw+4FqA0JPMr++AgE4WI+KmXda1IosaU2yk/vE7vw=";
    yarnLock = "${src}/yarn.lock";
  };

  pyproject = true;
  pythonImportsCheck = [ "jupyterlab_execute_time" ];

  meta = {
    description = "JupyterLab extension for displaying cell timings";
    homepage = "https://github.com/deshaw/jupyterlab-execute-time";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.vglfr ];
  };
}
