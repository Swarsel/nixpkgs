{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  geoarrow-c,
  geoarrow-types,
  geopandas,
  numpy,
  pandas,
  pyarrow,
  pyarrow-hotfix,
  pyogrio,
  pyproj,
  pytestCheckHook,
  setuptools-scm,
}:
buildPythonPackage rec {
  pname = "geoarrow-pyarrow";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "geoarrow";
    repo = "geoarrow-python";
    tag = "geoarrow-types-${version}";
    hash = "sha256-ciElwh94ukFyFdOBuQWyOUVpn4jBM1RKfxiBCcM+nmE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  checkInputs = [
    geoarrow-types
    numpy
    pandas
    geopandas
    pyogrio
    pyproj
  ];

  build-system = [ setuptools-scm ];

  dependencies = [
    geoarrow-c
    pyarrow
    pyarrow-hotfix
  ];

  disabledTests = [
    # these tests are incompatible with arrow 17
    "test_make_point"
    "test_point_with_offset"
    "test_linestring_with_offset"
    "test_polygon_with_offset"
    "test_multipoint_with_offset"
    "test_multilinestring_with_offset"
    "test_multipolygon_with_offset"
    "test_multipolygon_with_offset_nonempty_inner_lists"
    "test_interleaved_multipolygon_with_offset"
    "test_readpyogrio_table_gpkg"
    "test_geometry_type_basic"
  ];

  pyproject = true;
  pythonImportsCheck = [ "geoarrow.pyarrow" ];
  sourceRoot = "${src.name}/geoarrow-pyarrow";

  meta = {
    description = "PyArrow implementation of geospatial data types";
    homepage = "https://github.com/geoarrow/geoarrow-python";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      cpcloud
    ];

    teams = [ lib.teams.geospatial ];
  };
}
