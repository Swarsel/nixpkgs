{
  lib,
  buildPythonPackage,
  configupdater,
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
  pname = "pyscaffoldext-travis";
  version = "0.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ztAhA/2ctCHz5kggOAaXd3ed903ClTlhCfaGTl344zI=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
    wheel
  ];

  propagatedBuildInputs = [
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
  pythonImportsCheck = [ "pyscaffoldext.travis" ];

  meta = {
    description = "Travis CI configurations for PyScaffold";
    homepage = "https://pypi.org/project/pyscaffoldext-travis/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ matthewcroughan ];
  };
}
