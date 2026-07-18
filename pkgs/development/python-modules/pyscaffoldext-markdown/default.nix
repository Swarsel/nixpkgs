{
  lib,
  buildPythonPackage,
  configupdater,
  fetchPypi,
  importlib-metadata,
  myst-parser,
  pre-commit,
  pyscaffold,
  pytest,
  pytest-cov,
  pytest-xdist,
  setuptools,
  setuptools-scm,
  tox,
  twine,
  virtualenv,
  wheel,
}:

buildPythonPackage rec {
  pname = "pyscaffoldext-markdown";
  version = "0.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-fycTscq9rjUNFidWyeoH4QwedthdCdqqjXDO9DC4tds=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
    wheel
  ];

  propagatedBuildInputs = [
    importlib-metadata
    myst-parser
    pyscaffold
    wheel
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
      twine
      virtualenv
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pyscaffoldext.markdown" ];

  meta = {
    description = "PyScaffold extension which uses Markdown instead of reStructuredText";
    homepage = "https://pypi.org/project/pyscaffoldext-markdown/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ matthewcroughan ];
  };
}
