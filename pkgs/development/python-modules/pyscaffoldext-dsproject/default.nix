{
  lib,
  buildPythonPackage,
  configupdater,
  fetchPypi,
  importlib-metadata,
  pre-commit,
  pyscaffold,
  pyscaffoldext-markdown,
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
  pname = "pyscaffoldext-dsproject";
  version = "0.7.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-SF99noD6C31p4LWlwVAwArPYeNspF+ARK8Dzl5B1T9g=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
    wheel
  ];

  propagatedBuildInputs = [
    importlib-metadata
    pyscaffold
    pyscaffoldext-markdown
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
  pythonImportsCheck = [ "pyscaffoldext.dsproject" ];

  meta = {
    description = "PyScaffold extension for Data Science projects";
    homepage = "https://pypi.org/project/pyscaffoldext-dsproject/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ matthewcroughan ];
  };
}
