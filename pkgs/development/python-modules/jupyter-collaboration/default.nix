{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  dirty-equals,
  # build-system
  hatchling,
  httpx-ws,
  # dependencies
  jupyter-collaboration-ui,
  jupyter-docprovider,
  jupyter-server-ydoc,
  jupyterlab,
  pytest-jupyter,
  pytest-timeout,
  pytestCheckHook,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "jupyter-collaboration";
  version = "4.4.0";

  src = fetchFromGitHub {
    owner = "jupyterlab";
    repo = "jupyter-collaboration";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6FF4KtQSIrB0LeJDNMWWpRIAxRkFMzz566WB6H5ePXs=";
  };

  nativeCheckInputs = [
    dirty-equals
    httpx-ws
    pytest-jupyter
    pytest-timeout
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  preCheck = ''
    appendToVar enabledTestPaths "$src/tests"
  '';

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    jupyter-collaboration-ui
    jupyter-docprovider
    jupyter-server-ydoc
    jupyterlab
  ];

  disabledTests = [
    # Failed: Timeout (>300.0s) from pytest-timeout
    "test_document_ttl_from_settings"
  ];

  pyproject = true;

  pytestFlags = [
    # pytest.PytestCacheWarning: could not create cache path /build/source/.pytest_cache/v/cache/nodeids: [Errno 13] Permission denied: '/build/source/pytest-cache-files-plraagdr'
    "-pno:cacheprovider"
  ];

  pythonImportsCheck = [ "jupyter_collaboration" ];
  sourceRoot = "${finalAttrs.src.name}/projects/jupyter-collaboration";

  meta = {
    description = "JupyterLab Extension enabling Real-Time Collaboration";
    homepage = "https://github.com/jupyterlab/jupyter_collaboration";
    changelog = "https://github.com/jupyterlab/jupyter_collaboration/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    teams = [ lib.teams.jupyter ];
  };
})
