{
  lib,
  buildPythonPackage,
  configupdater,
  fetchPypi,
  importlib-metadata,
  packaging,
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
  pname = "pyscaffoldext-custom-extension";
  version = "0.6.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-xHtKNqLSCTlbbXubADfLYjD3/53WfM65rRuh9RsyeN4=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
    wheel
  ];

  propagatedBuildInputs = [
    configupdater
    importlib-metadata
    packaging
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
  pythonImportsCheck = [ "pyscaffoldext.custom_extension" ];

  meta = {
    description = "PyScaffold extension to create a custom PyScaffold extension";
    homepage = "https://pypi.org/project/pyscaffoldext-custom-extension/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ matthewcroughan ];
  };
}
