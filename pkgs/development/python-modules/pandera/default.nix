{
  lib,
  stdenv,
  fetchFromGitHub,
  # optional-dependencies
  black,
  buildPythonPackage,
  dask,
  duckdb,
  fastapi,
  frictionless,
  geopandas,
  hypothesis,
  ibis-framework,
  # tests
  joblib,
  # dependencies
  numpy,
  packaging,
  pandas,
  pandas-stubs,
  polars,
  pyarrow,
  pyarrow-hotfix,
  pydantic,
  pytest-asyncio,
  pytestCheckHook,
  pythonAtLeast,
  pyyaml,
  rich,
  scipy,
  # build-system
  setuptools,
  setuptools-scm,
  shapely,
  typeguard,
  typing-extensions,
  typing-inspect,
}:

buildPythonPackage (finalAttrs: {
  pname = "pandera";
  version = "0.30.1";

  src = fetchFromGitHub {
    owner = "unionai-oss";
    repo = "pandera";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JmD8p0Syt/Tgf9LiMWeug1dSPp4cyd7BtBfo6yi08xg=";
  };

  nativeCheckInputs = [
    joblib
    pyarrow
    pyarrow-hotfix
    pytest-asyncio
    pytestCheckHook
    rich
  ]
  ++ finalAttrs.passthru.optional-dependencies.all;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    packaging
    pydantic
    typeguard
    typing-extensions
    typing-inspect
  ];

  disabledTestPaths = [
    "tests/fastapi/test_app.py" # tries to access network
    "tests/pandas/test_docs_setting_column_widths.py" # tests doc generation, requires sphinx
    "tests/modin" # requires modin, not in nixpkgs
    "tests/mypy/test_pandas_static_type_checking.py" # some typing failures
    "tests/pyspark" # requires spark

    # KeyError: 'dask'
    "tests/dask/test_dask.py::test_series_schema"
    "tests/dask/test_dask_accessor.py::test_dataframe_series_add_schema"

    # TypeError: memtable() got an unexpected keyword argument 'name'
    # https://github.com/unionai-oss/pandera/issues/2154
    "tests/ibis/test_ibis_container.py"
  ];

  disabledTests = [
    # TypeError: __class__ assignment: 'GeoDataFrame' object...
    "test_schema_model"
    "test_schema_from_dataframe"
    "test_schema_no_geometry"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # OOM error on ofborg:
    "test_engine_geometry_coerce_crs"
    # pandera.errors.SchemaError: Error while coercing 'geometry' to type geometry
    "test_schema_dtype_crs_with_coerce"
  ]
  ++ lib.optionals (pythonAtLeast "3.13") [
    # AssertionError: assert DataType(Sparse[float64, nan]) == DataType(Sparse[float64, nan])
    "test_legacy_default_pandas_extension_dtype"
  ];

  optional-dependencies =
    let
      dask-dataframe = [ dask ] ++ dask.optional-dependencies.dataframe;
      extras = {
        # pyspark expression does not define optional-dependencies.connect:
        #pyspark = [ pyspark ] ++ pyspark.optional-dependencies.connect;
        # modin not in nixpkgs:
        #modin = [
        #  modin
        #  ray
        #] ++ dask-dataframe;
        #modin-ray = [
        #  modin
        #  ray
        #];
        #modin-dask = [
        #  modin
        #] ++ dask-dataframe;
        dask = dask-dataframe;
        fastapi = [ fastapi ];

        geopandas = [
          geopandas
          shapely
        ];

        hypotheses = [ scipy ];

        ibis = [
          ibis-framework
          duckdb
        ];

        io = [
          pyyaml
          black
          frictionless
        ];

        mypy = [ pandas-stubs ];

        pandas = [
          numpy
          pandas
        ];

        polars = [ polars ];
        strategies = [ hypothesis ];
      };
    in
    extras // { all = lib.concatLists (lib.attrValues extras); };

  pyproject = true;

  pythonImportsCheck = [
    "pandera"
    "pandera.api"
    "pandera.config"
    "pandera.dtypes"
    "pandera.engines"
  ];

  meta = {
    description = "Light-weight, flexible, and expressive statistical data testing library";
    homepage = "https://pandera.readthedocs.io";
    changelog = "https://github.com/unionai-oss/pandera/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
})
