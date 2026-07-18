{
  lib,
  buildPythonPackage,
  fetchPypi,
  ipykernel,
  ipywidgets,
  jupyter-console,
  jupyterlab,
  nbconvert,
  notebook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "jupyter";
  version = "1.1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-1VRnvOq96knX42JK9+M9WcN//1PtOjUOGslXvtcx3no=";
  };

  # Meta-package, no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    ipykernel
    ipywidgets
    jupyter-console
    jupyterlab
    nbconvert
    notebook
  ];

  dontUsePythonImportsCheck = true;
  pyproject = true;

  meta = {
    description = "Installs all the Jupyter components in one go";
    homepage = "https://jupyter.org/";
    license = lib.licenses.bsd3;
    priority = 100; # This is a metapackage which is unimportant
  };
}
