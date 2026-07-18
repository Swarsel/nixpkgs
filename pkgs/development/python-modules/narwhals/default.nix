{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  dask,
  duckdb,
  hypothesis,
  ibis-framework,
  packaging,
  pandas,
  polars,
  pyarrow,
  pyarrow-hotfix,
  pyspark,
  pytest-env,
  pytest-xdist,
  pytestCheckHook,
  rich,
  sqlframe,
  uv-build,
}:

buildPythonPackage rec {
  pname = "narwhals";
  version = "2.23.0";

  src = fetchFromGitHub {
    owner = "narwhals-dev";
    repo = "narwhals";
    tag = "v${version}";
    hash = "sha256-fT3v7T2S7cmv0tX60kjRBrUq+89TG2/Ar9Qh9O4LP8U=";
  };

  nativeCheckInputs = [
    duckdb
    hypothesis
    pytest-env
    pytest-xdist
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ uv-build ];

  disabledTestPaths = lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64) [
    # Segfault in included polars/lazyframe
    "tests/tpch_q1_test.py"
  ];

  disabledTests = [
    # Flaky
    "test_rolling_var_hypothesis"
    # Missing file
    "test_pyspark_connect_deps_2517"
    # Timezone issue
    "test_to_datetime"
    "test_unary_two_elements"
    # Test requires pyspark binary
    "test_datetime_w_tz_pyspark"
    "test_convert_time_zone_to_connection_tz_pyspark"
    "test_replace_time_zone_to_connection_tz_pyspark"
    "test_lazy"
    # Incompatible with ibis 11
    "test_unique_3069"
    # DuckDB 1.4.x compatibility - empty result schema handling with PyArrow
    "test_skew_expr"
    # ibis improvements cause strict XPASS failures (tests expected to fail now pass)
    "test_empty_scalar_reduction_with_columns"
    "test_collect_empty"
    "test_first_last_expr_over_order_by"
    "test_first_expr_broadcasting"
    # sqlframe improvements cause strict XPASS failures (tests expected to fail now pass)
    "test_unique_expr"
    # sqlframe issues
    "test_over_quantile"
    "test_quantile_expr"
    "test_join_duplicate_column_names"
  ];

  optional-dependencies = {
    # cudf = [ cudf ];
    dask = [ dask ] ++ dask.optional-dependencies.dataframe;

    ibis = [
      ibis-framework
      rich
      packaging
      pyarrow-hotfix
    ];

    # modin = [ modin ];
    pandas = [ pandas ];
    polars = [ polars ];
    pyarrow = [ pyarrow ];
    pyspark = [ pyspark ];
    sqlframe = [ sqlframe ];
  };

  pyproject = true;

  pytestFlags = [
    "-Wignore::DeprecationWarning"
  ];

  pythonImportsCheck = [ "narwhals" ];

  meta = {
    description = "Lightweight and extensible compatibility layer between dataframe libraries";
    homepage = "https://github.com/narwhals-dev/narwhals";
    changelog = "https://github.com/narwhals-dev/narwhals/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
