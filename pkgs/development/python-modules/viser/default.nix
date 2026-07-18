{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchNpmDeps,
  gdown,
  # build-system
  hatchling,
  # optional-dependencies
  hypothesis,
  # dependencies
  imageio,
  liblzfse,
  matplotlib,
  msgspec,
  nodeenv,
  # nativeBuildInputs
  nodejs,
  npmHooks,
  numpy,
  opencv-python,
  pandas,
  playwright,
  playwright-driver,
  plotly,
  plyfile,
  pre-commit,
  psutil,
  pyright,
  pytest,
  pytest-playwright,
  pytest-xdist,
  # nativeCheckInputs
  pytestCheckHook,
  requests,
  rich,
  robot-descriptions,
  ruff,
  torch,
  tqdm,
  trimesh,
  typing-extensions,
  tyro,
  websockets,
  yourdfpy,
  zstandard,
}:

buildPythonPackage (finalAttrs: {
  pname = "viser";
  version = "1.0.30";

  src = fetchFromGitHub {
    owner = "viser-project";
    repo = "viser";
    tag = "v${finalAttrs.version}";
    hash = "sha256-f9dUF2zz3KNIt+/Sgpb0MLiCNXoKUmXeyY3XlBblVzk=";
  };

  postPatch = ''
    # prepare npm offline cache
    mkdir -p node_modules
    cd src/viser/client
    cp package.json package-lock.json ../../..
    ln -s ../../../node_modules
    cd ../../..
  '';

  nativeBuildInputs = [
    npmHooks.npmConfigHook
    nodejs
  ];

  env = {
    PLAYWRIGHT_BROWSERS_PATH = playwright-driver.browsers;
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = true;
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = true;
  };

  preBuild = ''
    cd src/viser/client
    npm --offline run build
    cd ../../..
  '';

  nativeCheckInputs = [
    hypothesis
    playwright-driver
    pytestCheckHook
  ];

  # adding pre-commit here break PYTHONPATH in 3.14
  checkInputs = lib.filter (p: p.pname != "pre-commit") finalAttrs.passthru.optional-dependencies.dev;
  __darwinAllowLocalNetworking = true;

  build-system = [
    hatchling
  ];

  dependencies = [
    imageio
    msgspec
    numpy
    requests
    rich
    tqdm
    trimesh
    typing-extensions
    websockets
    zstandard
  ];

  disabledTestPaths = [
    # too many flaky tests
    "tests/e2e"
  ];

  disabledTests = [
    # assert 0 != 0
    # (only when xdist)
    "test_server_port_is_freed"

    # counts ffmpeg pids, can be confused when
    # building multiple times this package in parallel
    "test_process_termination"
  ];

  npmDeps = fetchNpmDeps {
    src = finalAttrs.src + "/src/viser/client/";
    hash = "sha256-mx5vqgiZRWYruDbjAPgCCc7hewTqH9jsXrerL8XbOMY=";
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
  };

  optional-dependencies = {
    dev = [
      hypothesis
      nodeenv
      playwright
      pre-commit
      psutil
      pyright
      pytest
      pytest-playwright
      pytest-xdist
      ruff
    ]
    ++ finalAttrs.passthru.optional-dependencies.examples;

    examples = [
      gdown
      liblzfse
      matplotlib
      opencv-python
      pandas
      plotly
      plyfile
      robot-descriptions
      torch
      tyro
    ]
    ++ finalAttrs.passthru.optional-dependencies.urdf;

    urdf = [ yourdfpy ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "viser"
  ];

  pythonRelaxDeps = [
    # rich<15.0.0,>=13.3.3 not satisfied by version 15.0.0
    "rich"
  ];

  meta = {
    description = "Web-based 3D visualization in Python";
    homepage = "https://github.com/viser-project/viser";
    changelog = "https://github.com/viser-project/viser/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nim65s ];
  };
})
