{
  lib,
  stdenv,
  fetchFromGitHub,
  bokeh,
  buildPythonPackage,
  # dependencies
  click,
  cloudpickle,
  distributed,
  fsspec,
  # tests
  hypothesis,
  importlib-metadata,
  jinja2,
  lz4,
  # optional-dependencies
  numpy,
  packaging,
  pandas,
  partd,
  psutil,
  pyarrow,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-mock,
  pytest-rerunfailures,
  pytest-timeout,
  pytest-xdist,
  pytestCheckHook,
  pythonAtLeast,
  pyyaml,
  # build-system
  setuptools,
  setuptools-scm,
  toolz,
  util-linux,
  versionCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "dask";
  version = "2026.7.0";

  src = fetchFromGitHub {
    owner = "dask";
    repo = "dask";
    tag = finalAttrs.version;
    hash = "sha256-Lp8l4luwCGUmLWzwhAYBn8lrXH2bLTnMO7JCD+TqrKU=";
  };

  postPatch = lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace dask/tests/test_system.py \
      --replace-fail \
        '"taskset",' \
        '"${lib.getExe' util-linux "taskset"}",'
  '';

  nativeCheckInputs = [
    hypothesis
    psutil
    pyarrow
    pytest-asyncio
    pytest-cov-stub
    pytest-mock
    pytest-rerunfailures
    pytest-timeout
    pytest-xdist
    pytestCheckHook
    versionCheckHook
  ]
  ++ finalAttrs.passthru.optional-dependencies.array
  ++ finalAttrs.passthru.optional-dependencies.dataframe;

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    click
    cloudpickle
    fsspec
    importlib-metadata
    packaging
    partd
    pyyaml
    toolz
  ];

  disabledTestMarks = [
    # Don't run tests that require network access
    "network"
  ];

  disabledTests = [
    # https://github.com/dask/dask/issues/10931
    "test_combine_first_all_nans"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # RuntimeWarning: divide by zero encountered in det
    "test_array_notimpl_function_dask"
  ]
  ++ lib.optionals (pythonAtLeast "3.14") [
    # https://github.com/dask/dask/issues/12042
    "test_multiple_repartition_partition_size"
  ];

  optional-dependencies = lib.fix (self: {
    array = [ numpy ];

    complete = [
      pyarrow
      lz4
    ]
    ++ self.array
    ++ self.dataframe
    ++ self.distributed
    ++ self.diagnostics;

    dataframe = [
      pandas
      pyarrow
    ]
    ++ self.array;

    diagnostics = [
      bokeh
      jinja2
    ];

    distributed = [ distributed ];
  });

  pyproject = true;

  pytestFlags = [
    # Rerun failed tests up to three times
    "--reruns=3"

    # FutureWarning: The previous implementation of stack is deprecated and will be removed in a
    # future version of pandas.
    "-Wignore::FutureWarning"
  ];

  pythonImportsCheck = [
    "dask"
    "dask.bag"
    "dask.bytes"
    "dask.diagnostics"

    # Requires the `dask.optional-dependencies.array` that are only in `nativeCheckInputs`
    "dask.array"
    # Requires the `dask.optional-dependencies.dataframe` that are only in `nativeCheckInputs`
    "dask.dataframe"
    "dask.dataframe.io"
    "dask.dataframe.tseries"
  ];

  meta = {
    description = "Minimal task scheduling abstraction";
    homepage = "https://dask.org/";
    changelog = "https://docs.dask.org/en/latest/changelog.html";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    mainProgram = "dask";
  };
})
