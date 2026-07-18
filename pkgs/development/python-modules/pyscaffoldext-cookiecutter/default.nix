{
  lib,
  buildPythonPackage,
  configupdater,
  cookiecutter,
  fetchPypi,
  importlib-metadata,
  pre-commit,
  pyscaffold,
  pytest,
  pytest-cov,
  pytest-xdist,
  setuptools,
  setuptools-scm,
  tox,
  virtualenv,
  wheel,
}:

buildPythonPackage rec {
  pname = "pyscaffoldext-cookiecutter";
  version = "0.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-H++p/kPASs3IWk39fCXzq20QmMPGkG0bDTnVAm773cU=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
    wheel
  ];

  propagatedBuildInputs = [
    cookiecutter
    importlib-metadata
    pyscaffold
  ];

  optional-dependencies = {
    testing = [
      configupdater
      pre-commit
      pytest
      pytest-cov
      pytest-xdist
      setuptools-scm
      tox
      virtualenv
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pyscaffoldext.cookiecutter" ];

  meta = {
    description = "Integration of Cookiecutter project templates into PyScaffold (see: https://github.com/cookiecutter/cookiecutter";
    homepage = "https://pypi.org/project/pyscaffoldext-cookiecutter/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ matthewcroughan ];
  };
}
