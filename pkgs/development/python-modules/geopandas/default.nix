{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # optional-dependencies
  folium,
  geoalchemy2,
  geopy,
  mapclassify,
  matplotlib,
  # dependencies
  packaging,
  pandas,
  psycopg,
  pyarrow,
  pyogrio,
  pyproj,
  # tests
  pytestCheckHook,
  rtree,
  # build-system
  setuptools,
  shapely,
  sqlalchemy,
  writableTmpDirAsHomeHook,
  xyzservices,
}:

buildPythonPackage (finalAttrs: {
  pname = "geopandas";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "geopandas";
    repo = "geopandas";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7XWPPLuJjc6x+Vb16z0bEjYe1lX710vz5Rwjg/WFHH0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    rtree
    writableTmpDirAsHomeHook
  ]
  ++ finalAttrs.passthru.optional-dependencies.all;

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    packaging
    pandas
    pyogrio
    pyproj
    shapely
  ];

  disabledTests = [
    # Requires network access
    "test_read_file_url"
  ];

  enabledTestPaths = [ "geopandas" ];

  optional-dependencies = {
    all = [
      # prevent infinite recursion
      (folium.overridePythonAttrs (prevAttrs: {
        doCheck = false;
      }))
      geoalchemy2
      geopy
      # prevent infinite recursion
      (mapclassify.overridePythonAttrs (prevAttrs: {
        doCheck = false;
      }))
      matplotlib
      psycopg
      pyarrow
      sqlalchemy
      xyzservices
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "geopandas" ];

  meta = {
    description = "Python geospatial data analysis framework";
    homepage = "https://geopandas.org";
    changelog = "https://github.com/geopandas/geopandas/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    teams = [ lib.teams.geospatial ];
  };
})
