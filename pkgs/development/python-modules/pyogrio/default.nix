{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  certifi,
  # build-system
  cython,
  # tests
  fiona,
  gdal,
  numpy,
  packaging,
  pandas,
  pytest-benchmark,
  pytestCheckHook,
  setuptools,
  versioneer,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyogrio";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "geopandas";
    repo = "pyogrio";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9WaJMrh3FN4hWpdGNq2TynoLqT91tLQ7iTTl/NWYQTI=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail \
        "versioneer[toml]==0.28" \
        "versioneer[toml]"
  '';

  nativeBuildInputs = [
    gdal # for gdal-config
  ];

  buildInputs = [ gdal ];

  nativeCheckInputs = [
    fiona
    pandas
    pytestCheckHook
    pytest-benchmark
  ];

  preCheck = ''
    rm pyogrio/__init__.py
  '';

  __structuredAttrs = true;

  build-system = [
    cython
    setuptools
    versioneer
  ];

  dependencies = [
    certifi
    numpy
    packaging
  ];

  disabledTestMarks = [
    # disable tests which require network access
    "network"
  ];

  disabledTestPaths = [
    # NameError: name 'shapely' is not defined
    "pyogrio/tests/test_geopandas_io.py"
  ];

  disabledTests = [
    # Circular dependencies with geopandas
    "test_detect_zip_path"
    "test_path_absolute"
    "test_path_relative_dataframe"
    "test_uri_local_file_dataframe"
    "test_vsi_handling_read_dataframe"
    "test_zip_path_dataframe"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyogrio" ];

  meta = {
    description = "Vectorized spatial vector file format I/O using GDAL/OGR";
    homepage = "https://pyogrio.readthedocs.io/";
    changelog = "https://github.com/geopandas/pyogrio/blob/${finalAttrs.src.tag}/CHANGES.md";
    license = lib.licenses.mit;
    teams = [ lib.teams.geospatial ];
  };
})
