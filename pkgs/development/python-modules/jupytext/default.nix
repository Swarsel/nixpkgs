{
  lib,
  stdenv,
  fetchFromGitHub,
  # tests
  addBinToPathHook,
  buildPythonPackage,
  # build-system
  hatch-jupyter-builder,
  hatchling,
  jupyter-client,
  jupyterlab,
  # dependencies
  markdown-it-py,
  mdit-py-plugins,
  nbformat,
  nodejs,
  notebook,
  packaging,
  pytest-asyncio,
  pytest-xdist,
  pytestCheckHook,
  pyyaml,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  yarn-berry_3,
}:

buildPythonPackage rec {
  pname = "jupytext";
  version = "1.18.1";

  src = fetchFromGitHub {
    owner = "mwouts";
    repo = "jupytext";
    tag = "v${version}";
    hash = "sha256-D7Ps/lHF3F/7Jm4ozcjO8YsTPA1GQPqZVpPod/riGvA=";
  };

  patches = [
    ./fix-yarn-lock-typescript.patch
  ];

  nativeBuildInputs = [
    nodejs
    yarn-berry_3.yarnBerryConfigHook
  ];

  env.HATCH_BUILD_HOOKS_ENABLE = true;

  preConfigure = ''
    pushd jupyterlab
  '';

  preBuild = ''
    popd
  '';

  nativeCheckInputs = [
    addBinToPathHook
    jupyter-client
    notebook
    pytest-asyncio
    pytest-xdist
    pytestCheckHook
    versionCheckHook
    # Tests that use a Jupyter notebook require $HOME to be writable
    writableTmpDirAsHomeHook
  ];

  preCheck = ''
    substituteInPlace tests/functional/contents_manager/test_async_and_sync_contents_manager_are_in_sync.py \
      --replace-fail "from black import FileMode, format_str" "" \
      --replace-fail "format_str(sync_code, mode=FileMode())" "sync_code"
  '';

  build-system = [
    hatch-jupyter-builder
    hatchling
    jupyterlab
  ];

  dependencies = [
    markdown-it-py
    mdit-py-plugins
    nbformat
    packaging
    pyyaml
  ];

  disabledTestPaths = [
    # Requires the `git` python module
    "tests/external"
  ];

  disabledTests = [
    # Fails due to whitespace differences in the outputs
    "test_async_and_sync_files_are_in_sync"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # requires access to trash
    "test_load_save_rename"
  ];

  missingHashes = ./missing-hashes.json;

  offlineCache = yarn-berry_3.fetchYarnBerryDeps {
    inherit src missingHashes;

    patches = [
      ./fix-yarn-lock-typescript-offline-cache.patch
    ];

    hash = "sha256-k2lQnlSmCghIkp6VwNmq5KpSHS5tEbnFnsM+xqo3Ebw=";
    sourceRoot = "${src.name}/jupyterlab";
  };

  pyproject = true;

  pythonImportsCheck = [
    "jupytext"
    "jupytext.cli"
  ];

  meta = {
    description = "Jupyter notebooks as Markdown documents, Julia, Python or R scripts";
    homepage = "https://github.com/mwouts/jupytext";
    changelog = "https://github.com/mwouts/jupytext/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "jupytext";
    teams = [ lib.teams.jupyter ];
  };
}
