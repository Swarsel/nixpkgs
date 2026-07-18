{
  lib,
  # dependencies
  aiohttp,
  backoff,
  bokeh,
  boto3,
  buildPythonPackage,
  click,
  dask,
  distributed,
  fabric,
  fetchPypi,
  filelock,
  gilknocker,
  hatch-vcs,
  # build-system
  hatchling,
  httpx,
  importlib-metadata,
  invoke,
  ipywidgets,
  jmespath,
  jsondiff,
  paramiko,
  pip,
  pip-requirements-parser,
  prometheus-client,
  rich,
  toml,
  typing-extensions,
  # tests
  versionCheckHook,
  wheel,
}:

buildPythonPackage (finalAttrs: {
  pname = "coiled";
  version = "1.135.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-dI3AT4hogMHLAg7jyXuJNPHeJG9U0nEwwN+MQ+UgxTA=";
  };

  nativeCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    aiohttp
    backoff
    bokeh
    boto3
    click
    dask
    distributed
    fabric
    filelock
    gilknocker
    httpx
    importlib-metadata
    invoke
    ipywidgets
    jmespath
    jsondiff
    paramiko
    pip
    pip-requirements-parser
    prometheus-client
    rich
    toml
    typing-extensions
    wheel
  ];

  pyproject = true;
  pythonImportsCheck = [ "coiled" ];

  meta = {
    description = "Python client for coiled.io dask clusters";
    homepage = "https://www.coiled.io/";
    license = lib.licenses.elastic20;
    maintainers = with lib.maintainers; [ daspk04 ];
    mainProgram = "coiled";
  };
})
