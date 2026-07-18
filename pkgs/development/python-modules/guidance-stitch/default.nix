{
  lib,
  buildPythonPackage,
  fetchPypi,
  # build-system
  hatch-jupyter-builder,
  hatch-nodejs-version,
  hatchling,
  # dependencies
  ipywidgets,
  jupyterlab,
  # tests
  nbval,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "guidance-stitch";
  version = "0.1.5";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Kg0O3oZds4eFfUlKe8sakDYhwT9XGGnN4RCcLFVpzZU=";
    pname = "guidance_stitch";
  };

  nativeCheckInputs = [
    nbval
    pytest-cov-stub
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    hatch-jupyter-builder
    hatch-nodejs-version
    hatchling
    jupyterlab
  ];

  dependencies = [
    ipywidgets
  ];

  pyproject = true;
  pythonImportsCheck = [ "stitch" ];

  meta = {
    description = "Guidance language for controlling large language models";
    homepage = "https://github.com/guidance-ai/guidance/tree/main/packages/python/stitch";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
