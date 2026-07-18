{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchNpmDeps,
  # build-system
  hatch-deps-selector,
  hatch-jupyter-builder,
  hatch-nodejs-version,
  hatchling,
  ipykernel,
  # dependencies
  jupyter-core,
  jupyter-server,
  nodeenv,
  # nativeBuildInputs
  nodejs,
  npmHooks,
  # tests
  versionCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "jupyter-book";
  version = "2.1.5";

  src = fetchFromGitHub {
    owner = "jupyter-book";
    repo = "jupyter-book";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0osykGqNr16il67ubfglTchTl3anQWrjlaySxBWh/yk=";
  };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  # jupyter-book requires node at runtime
  propagatedBuildInputs = [
    nodejs
  ];

  # No python tests
  nativeCheckInputs = [
    versionCheckHook
  ];

  build-system = [
    hatch-deps-selector
    hatch-jupyter-builder
    hatch-nodejs-version
    hatchling
  ];

  dependencies = [
    ipykernel
    jupyter-core
    jupyter-server
    nodeenv
  ];

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-H7ZsDMNXU9u0jvmbrcWzUoFjD+y1OlmNVLK9WEfDJyU=";
  };

  pyproject = true;
  pythonImportsCheck = [ "jupyter_book" ];
  versionCheckProgramArg = "--version";

  meta = {
    description = "Build a book with Jupyter Notebooks and Sphinx";
    homepage = "https://jupyterbook.org/";
    changelog = "https://github.com/jupyter-book/jupyter-book/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    mainProgram = "jupyter-book";
    teams = [ lib.teams.jupyter ];
  };
})
