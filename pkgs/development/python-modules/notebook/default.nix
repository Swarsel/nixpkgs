{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  distutils,
  # build-system
  hatch-jupyter-builder,
  hatchling,
  # dependencies
  jupyter-server,
  jupyterlab,
  jupyterlab-server,
  # nativeBuildInputs
  nodejs,
  notebook-shim,
  # tests
  pytest-jupyter,
  pytestCheckHook,
  tornado,
  yarn-berry_3,
}:

buildPythonPackage rec {
  pname = "notebook";
  version = "7.5.6";

  src = fetchFromGitHub {
    owner = "jupyter";
    repo = "notebook";
    tag = "v${version}";
    hash = "sha256-xEwXiYQ7OiQ4dEL4ewP+yr3tGsWqa1hAUIl0Th48aiU=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "timeout = 300" ""
  '';

  nativeBuildInputs = [
    nodejs
    yarn-berry_3.yarnBerryConfigHook
  ]
  ++ lib.optionals (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64) [
    distutils
  ];

  env = {
    CI = 1; # quiet lerna progress bar
    JUPYTER_PLATFORM_DIRS = 1;
  };

  nativeCheckInputs = [
    pytest-jupyter
    pytestCheckHook
  ];

  # Some of the tests use localhost networking.
  __darwinAllowLocalNetworking = true;

  build-system = [
    hatch-jupyter-builder
    hatchling
    jupyterlab
  ];

  dependencies = [
    jupyter-server
    jupyterlab
    jupyterlab-server
    notebook-shim
    tornado
  ];

  missingHashes = ./missing-hashes.json;

  offlineCache = yarn-berry_3.fetchYarnBerryDeps {
    inherit src missingHashes;
    hash = "sha256-BdoAtG7Dc+ZTBn4bCraAIazvXiZyvG5u97pcwvptjBY=";
  };

  pyproject = true;

  pytestFlags = [
    "-Wignore::DeprecationWarning"
  ];

  meta = {
    description = "Web-based notebook environment for interactive computing";
    homepage = "https://github.com/jupyter/notebook";
    changelog = "https://github.com/jupyter/notebook/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    mainProgram = "jupyter-notebook";
    teams = [ lib.teams.jupyter ];
  };
}
