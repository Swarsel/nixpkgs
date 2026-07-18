{
  lib,
  buildPythonPackage,
  fetchPypi,
  jupyter-lsp,
  jupyterlab,
  setuptools,
}:

buildPythonPackage rec {
  pname = "jupyterlab-lsp";
  version = "5.3.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-vfAU/rwOwpf/aQh+lXVJ1yTrDCnfPyTU9MQHWKca/D8=";
    pname = "jupyterlab_lsp";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    jupyterlab
    jupyter-lsp
  ];

  # No tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "jupyterlab_lsp" ];

  meta = {
    description = "Language Server Protocol integration for Jupyter(Lab)";
    homepage = "https://github.com/jupyter-lsp/jupyterlab-lsp";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
