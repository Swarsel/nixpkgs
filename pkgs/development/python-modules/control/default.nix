{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cvxopt,
  matplotlib,
  numpy,
  numpydoc,
  pytest-timeout,
  pytestCheckHook,
  scipy,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "control";
  version = "0.10.2";

  src = fetchFromGitHub {
    owner = "python-control";
    repo = "python-control";
    tag = version;
    hash = "sha256-E9RZDUK01hzjutq83XdLr3d97NwjmQzt65hqVg2TBGE=";
  };

  nativeCheckInputs = [
    numpydoc
    pytest-timeout
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    numpy
    scipy
    matplotlib
  ];

  disabledTestPaths = [
    # Don't test the docs
    "doc/test_sphinxdocs.py"
  ];

  optional-dependencies = {
    # slycot is not in nixpkgs
    # slycot = [ slycot ];
    cvxopt = [ cvxopt ];
  };

  pyproject = true;
  pythonImportsCheck = [ "control" ];

  meta = {
    description = "Python Control Systems Library";
    homepage = "https://github.com/python-control/python-control";
    changelog = "https://github.com/python-control/python-control/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ Peter3579 ];
  };
}
