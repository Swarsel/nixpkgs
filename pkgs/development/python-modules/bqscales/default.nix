{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-build-scripts,
  hatch-jupyter-builder,
  hatch-nodejs-version,
  # build-system
  hatchling,
  # dependencies
  ipywidgets,
  jupyterlab,
  # frontend
  nodejs,
  numpy,
  traitlets,
  traittypes,
  yarn-berry_3,
}:

buildPythonPackage (finalAttrs: {
  pname = "bqscales";
  version = "0.3.7";

  src = fetchFromGitHub {
    owner = "bqplot";
    repo = "bqscales";
    tag = finalAttrs.version;
    hash = "sha256-AAKnOEwdycSlxJEK0qbFJp2Dpiw/rEIk7fUa3NTymqQ=";
  };

  postPatch = ''
    sed -i "/\"hatch\"/d" pyproject.toml
  '';

  nativeBuildInputs = [
    nodejs
    yarn-berry_3.yarnBerryConfigHook
    yarn-berry_3
  ];

  env.SKIP_JUPYTER_BUILDER = 1;

  preBuild = ''
    npm run build
  '';

  # no tests in PyPI dist
  doCheck = false;

  build-system = [
    hatch-build-scripts
    hatch-jupyter-builder
    hatch-nodejs-version
    hatchling
    jupyterlab
  ];

  dependencies = [
    ipywidgets
    numpy
    traitlets
    traittypes
  ];

  missingHashes = ./missing-hashes.json;
  pyproject = true;
  pythonImportsCheck = [ "bqscales" ];

  yarnOfflineCache = yarn-berry_3.fetchYarnBerryDeps {
    inherit (finalAttrs) src missingHashes;
    hash = "sha256-4Y5dRFwOyfHOzrdw2/epK3mN/+xrz+ccG86KP9axxjI=";
  };

  meta = {
    description = "Grammar of Graphics scales for bqplot and other Jupyter widgets libraries";
    homepage = "https://github.com/bqplot/bqscales";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
})
