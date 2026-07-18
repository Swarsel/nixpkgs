{
  lib,
  babel,
  buildPythonPackage,
  fetchPypi,
  ipykernel,
  ipython-genutils,
  jupyter-packaging,
  jupyter-server,
  nest-asyncio,
  notebook-shim,
  pytest-jupyter,
  pytest-tornasync,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "nbclassic";
  version = "1.2.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-c27FBIOlRIWXHbITvpIH405R/BRMeDQ2JbaZF0I2RLo=";
  };

  nativeCheckInputs = [
    pytest-jupyter
    pytest-tornasync
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    babel
    jupyter-packaging
    jupyter-server
  ];

  dependencies = [
    ipykernel
    ipython-genutils
    nest-asyncio
    notebook-shim
  ];

  pyproject = true;
  pythonImportsCheck = [ "nbclassic" ];

  meta = {
    description = "Jupyter lab environment notebook server extension";
    homepage = "https://github.com/jupyter/nbclassic";
    license = with lib.licenses; [ bsd3 ];
  };
}
