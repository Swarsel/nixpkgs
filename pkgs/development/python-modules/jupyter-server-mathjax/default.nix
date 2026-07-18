{
  lib,
  buildPythonPackage,
  fetchPypi,
  jupyter-packaging,
  jupyter-server,
  pytest-jupyter,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "jupyter-server-mathjax";
  version = "0.2.6";

  src = fetchPypi {
    inherit version;
    hash = "sha256-ux5rbcBobB/jhqIrWIYWPbVIiTqZwoEMNjmenEyiOUM=";
    pname = "jupyter_server_mathjax";
  };

  nativeBuildInputs = [
    jupyter-packaging
    setuptools
  ];

  propagatedBuildInputs = [ jupyter-server ];

  nativeCheckInputs = [
    pytest-jupyter
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  pyproject = true;
  pythonImportsCheck = [ "jupyter_server_mathjax" ];

  meta = {
    description = "MathJax resources as a Jupyter Server Extension";
    homepage = "https://github.com/jupyter-server/jupyter_server_mathjax";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
