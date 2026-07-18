{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  fiona,
  geodatasets,
  geopandas,
  jinja2,
  numpy,
  packaging,
  pandas,
  platformdirs,
  pytestCheckHook,
  requests,
  scikit-learn,
  scipy,
  setuptools-scm,
  shapely,
}:

buildPythonPackage rec {
  pname = "libpysal";
  version = "4.14.1";

  src = fetchFromGitHub {
    owner = "pysal";
    repo = "libpysal";
    tag = "v${version}";
    hash = "sha256-epwviJtQ97MxUA4Gpw6SJceCdBPFXnZBF13A1HiJcOo=";
  };

  nativeCheckInputs = [
    geodatasets
    pytestCheckHook
  ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  build-system = [ setuptools-scm ];

  dependencies = [
    beautifulsoup4
    fiona
    geopandas
    jinja2
    numpy
    packaging
    pandas
    platformdirs
    requests
    scikit-learn
    scipy
    shapely
  ];

  # requires network access
  disabledTestPaths = [
    "libpysal/graph/tests/test_summary.py"
    "libpysal/cg/tests/test_geoJSON.py"
    "libpysal/examples/tests/test_available.py"
    "libpysal/graph/tests/test_base.py"
    "libpysal/graph/tests/test_builders.py"
    "libpysal/graph/tests/test_contiguity.py"
    "libpysal/graph/tests/test_kernel.py"
    "libpysal/graph/tests/test_matching.py"
    "libpysal/graph/tests/test_plotting.py"
    "libpysal/graph/tests/test_triangulation.py"
    "libpysal/graph/tests/test_utils.py"
    "libpysal/graph/tests/test_set_ops.py"
    "libpysal/weights/tests/test_contiguity.py"
    "libpysal/weights/tests/test_util.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "libpysal" ];

  meta = {
    description = "Library of spatial analysis functions";
    homepage = "https://pysal.org/libpysal/";
    changelog = "https://github.com/pysal/libpysal/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    teams = [ lib.teams.geospatial ];
  };
}
