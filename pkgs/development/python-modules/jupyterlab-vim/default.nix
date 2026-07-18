{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-jupyter-builder,
  hatch-nodejs-version,
  hatchling,
  jupyterlab,
}:

buildPythonPackage rec {
  pname = "jupyterlab-vim";
  version = "4.1.4";

  src = fetchPypi {
    inherit version;
    hash = "sha256-q/KJGq+zLwy5StmDIa5+vL4Mq+Uj042A1WnApQuFIlo=";
    pname = "jupyterlab_vim";
  };

  # has no tests
  doCheck = false;

  build-system = [
    hatchling
    hatch-jupyter-builder
    hatch-nodejs-version
  ];

  dependencies = [ jupyterlab ];
  pyproject = true;
  pythonImportsCheck = [ "jupyterlab_vim" ];

  meta = {
    description = "Vim notebook cell bindings for JupyterLab";
    homepage = "https://github.com/jupyterlab-contrib/jupyterlab-vim";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mart-mihkel ];
    platforms = lib.platforms.all;
  };
}
