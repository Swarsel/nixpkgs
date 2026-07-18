{
  lib,
  buildPythonPackage,
  comm,
  fetchPypi,
  ipykernel,
  ipython,
  jsonschema,
  jupyterlab-widgets,
  pytestCheckHook,
  pytz,
  setuptools,
  traitlets,
  widgetsnbextension,
}:

buildPythonPackage rec {
  pname = "ipywidgets";
  version = "8.1.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-YflpMGuV+F+6a2mGt/5F1zEk0dnjAjqAaHENR6Iupmg=";
  };

  nativeCheckInputs = [
    ipykernel
    jsonschema
    pytestCheckHook
    pytz
  ];

  build-system = [ setuptools ];

  dependencies = [
    comm
    ipython
    jupyterlab-widgets
    traitlets
    widgetsnbextension
  ];

  pyproject = true;

  meta = {
    description = "IPython HTML widgets for Jupyter";
    homepage = "https://github.com/jupyter-widgets/ipywidgets";
    license = lib.licenses.bsd3;
  };
}
