{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  # optional-dependencies
  lxml,
  matplotlib,
  numpy,
  pandas,
  pydot,
  pygraphviz,
  # tests
  pytest-xdist,
  pytestCheckHook,
  # reverse dependency
  sage,
  scipy,
  # build-system
  setuptools,
  sympy,
}:

buildPythonPackage rec {
  pname = "networkx";
  # upgrade may break sage, please test the sage build or ping @timokau on upgrade
  version = "3.6.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-JrfDV6zMDIzeVYrUhig3KLZbapXYXuHNZrr6tMgWhQk=";
  };

  nativeBuildInputs = [ setuptools ];

  nativeCheckInputs = [
    pytest-xdist
    pytestCheckHook
  ];

  disabledTests = [
    # No warnings of type (<class 'DeprecationWarning'>, <class 'PendingDeprecationWarning'>, <class 'FutureWarning'>) were emitted.
    "test_connected_raise"
  ];

  optional-dependencies = {
    default = [
      numpy
      scipy
      matplotlib
      pandas
    ];

    extra = [
      lxml
      pygraphviz
      pydot
      sympy
    ];
  };

  pyproject = true;

  passthru.tests = {
    inherit sage;
  };

  meta = {
    description = "Library for the creation, manipulation, and study of the structure, dynamics, and functions of complex networks";
    homepage = "https://networkx.github.io/";
    changelog = "https://github.com/networkx/networkx/blob/networkx-${version}/doc/release/release_${version}.rst";
    license = lib.licenses.bsd3;
    downloadPage = "https://github.com/networkx/networkx";
  };
}
