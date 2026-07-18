{
  lib,
  fetchFromGitHub,
  # tests
  anywidget,
  buildPythonPackage,
  igraph,
  ipywidgets,
  # dependencies
  jinja2,
  matplotlib,
  networkx,
  numpy,
  plotly,
  pytestCheckHook,
  scikit-learn,
  scipy,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "kmapper";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "scikit-tda";
    repo = "kepler-mapper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-i909J0yI8v8BqGbCkcjBAdA02Io+qpILdDkojZj0wv4=";
  };

  nativeCheckInputs = [
    anywidget
    igraph
    ipywidgets
    matplotlib
    networkx
    plotly
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    jinja2
    numpy
    scikit-learn
    scipy
  ];

  disabledTests = [
    # UnboundLocalError: cannot access local variable 'X_blend' where it is not associated with a value
    "test_tuple_projection"
    "test_tuple_projection_fit"
  ];

  pyproject = true;
  pythonImportsCheck = [ "kmapper" ];

  meta = {
    description = "Python implementation of Mapper algorithm for Topological Data Analysis";
    homepage = "https://kepler-mapper.scikit-tda.org/";
    changelog = "https://github.com/scikit-tda/kepler-mapper/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
    downloadPage = "https://github.com/scikit-tda/kepler-mapper";
  };
})
