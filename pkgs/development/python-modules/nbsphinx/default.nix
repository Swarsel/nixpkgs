{
  lib,
  buildPythonPackage,
  docutils,
  fetchPypi,
  jinja2,
  nbconvert,
  nbformat,
  setuptools,
  setuptools-scm,
  sphinx,
  traitlets,
}:

buildPythonPackage rec {
  pname = "nbsphinx";
  version = "0.9.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-0HZZCDmajuK1e+euiBzy6ljWbbOve78z5utI+DvqVJU=";
  };

  env.JUPYTER_PATH = "${nbconvert}/share/jupyter";
  # The package has not tests
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    docutils
    jinja2
    nbconvert
    nbformat
    sphinx
    traitlets
  ];

  pyproject = true;
  pythonImportsCheck = [ "nbsphinx" ];

  meta = {
    description = "Jupyter Notebook Tools for Sphinx";
    homepage = "https://nbsphinx.readthedocs.io/";
    changelog = "https://github.com/spatialaudio/nbsphinx/blob/${version}/NEWS.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
