{
  lib,
  buildPythonPackage,
  fetchPypi,
  jupyter-server,
  setuptools,
}:

buildPythonPackage rec {
  pname = "jupyter-lsp";
  version = "2.3.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-RYqlkzncho+3hNczZPF9vOiDbpBs11/UcaMly6AuAkU=";
    pname = "jupyter_lsp";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ jupyter-server ];
  # tests require network
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "jupyter_lsp" ];

  meta = {
    description = "Multi-Language Server WebSocket proxy for your Jupyter notebook or lab server";
    homepage = "https://jupyterlab-lsp.readthedocs.io/en/latest/";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
