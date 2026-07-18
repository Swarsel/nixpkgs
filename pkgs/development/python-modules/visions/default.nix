{
  lib,
  fetchFromGitHub,
  # dependencies
  attrs,
  buildPythonPackage,
  imagehash,
  matplotlib,
  multimethod,
  networkx,
  numpy,
  pandas,
  pillow,
  puremagic,
  pydot,
  pygraphviz,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
  # optional-dependencies
  shapely,
}:

buildPythonPackage rec {
  pname = "visions";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "dylan-profiler";
    repo = "visions";
    tag = "v${version}";
    hash = "sha256-MHseb1XJ0t7jQ45VXKQclYPgddrzmJAC7cde8qqYhNQ=";
  };

  nativeBuildInputs = [ setuptools ];

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  dependencies = [
    attrs
    multimethod
    networkx
    numpy
    pandas
    puremagic
  ];

  disabledTestPaths = [
    # requires running Apache Spark:
    "tests/spark_/typesets/test_spark_standard_set.py"

    # multimethod.DispatchError
    "tests/numpy_/typesets/test_standard_set.py::test_cast"
    "tests/numpy_/typesets/test_standard_set.py::test_conversion"
    "tests/numpy_/typesets/test_standard_set.py::test_inference"
  ];

  disabledTests = [
    # TypeError: Converting `np.inexact` or `np.floating` to a dtype not allowed
    "test_declarative"
  ];

  optional-dependencies = {
    plotting = [
      matplotlib
      pydot
      pygraphviz
    ];

    type-geometry = [ shapely ];

    type-image-path = [
      imagehash
      pillow
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "visions" ];

  meta = {
    description = "Type system for data analysis in Python";
    homepage = "https://dylan-profiler.github.io/visions";
    changelog = "https://github.com/dylan-profiler/visions/releases/tag/${src.tag}";
    license = lib.licenses.bsdOriginal;
    maintainers = with lib.maintainers; [ bcdarwin ];
    downloadPage = "https://github.com/dylan-profiler/visions";
  };
}
