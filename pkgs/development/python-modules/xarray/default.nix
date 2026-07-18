{
  lib,
  fetchFromGitHub,
  # optional-dependencies
  bottleneck,
  buildPythonPackage,
  cartopy,
  cftime,
  dask,
  fetchpatch,
  fsspec,
  h5netcdf,
  h5py,
  matplotlib,
  netcdf4,
  numba,
  numbagg,
  # dependencies
  numpy,
  opt-einsum,
  packaging,
  pandas,
  pooch,
  # tests
  pytest-asyncio,
  pytest-xdist,
  pytestCheckHook,
  scipy,
  seaborn,
  # build-system
  setuptools,
  setuptools-scm,
  sparse,
  zarr,
}:

buildPythonPackage (finalAttrs: {
  pname = "xarray";
  version = "2026.04.0";

  src = fetchFromGitHub {
    owner = "pydata";
    repo = "xarray";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BsgL+Xo9fTMLLdz5AfScnKGuBa76cE85LuUzB4ZNLiY=";
  };

  patches = [
    # Performance fix
    (fetchpatch {
      hash = "sha256-KzN45MqOBPMNEmoG+rb3iwrk/7XFLlTNktQf5uYBWNo=";
      url = "https://github.com/pydata/xarray/commit/b8bfeca3275045ca82adc3401c38444b1ed12c4a.patch";
    })
    # Fix tests with numpy >= 2.5.0
    (fetchpatch {
      excludes = [
        "doc/whats-new.rst"
      ];

      hash = "sha256-TakZ9RrJHeRksT3oBe7AKyfrjZeZ4oSmbE8axh7EmGg=";
      url = "https://github.com/pydata/xarray/commit/c3a398e856f7fcff1c18bc72bfd1ab9c64d5a2e7.patch";
    })
  ];

  postPatch = ''
    # don't depend on pytest-mypy-plugins
    sed -i "/--mypy-/d" pyproject.toml
  '';

  nativeCheckInputs = [
    pytest-asyncio
    pytest-xdist
    pytestCheckHook
  ]
  # Besides scipy, these are not strictly needed for the tests, but adding all
  # of these optional-dependencies extends the amount of tests from ~17k to
  # ~21k.
  ++ finalAttrs.finalPackage.optional-dependencies.io
  ++ finalAttrs.finalPackage.optional-dependencies.accel
  ++ finalAttrs.finalPackage.optional-dependencies.etc
  ++ finalAttrs.finalPackage.optional-dependencies.parallel
  # Not adding optional-dependencies.viz because adding cartopy causes infinite
  # recursion, and doesn't cause more tests to be collected.
  ;

  preCheck = ''
    # tests become flaky with to many cores
    export NIX_BUILD_CORES=$((NIX_BUILD_CORES > 8 ? 8 : NIX_BUILD_CORES))
  '';

  # Needed mainly for pytestFlags with spaces
  __structuredAttrs = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    numpy
    packaging
    pandas
  ];

  optional-dependencies = {
    accel = [
      bottleneck
      # flox
      numba
      numbagg
      opt-einsum
      scipy
    ];

    complete =
      with finalAttrs.finalPackage.passthru.optional-dependencies;
      accel ++ io ++ etc ++ parallel ++ viz;

    etc = [ sparse ];

    io = [
      netcdf4
      h5netcdf
      # pydap
      scipy
      zarr
      fsspec
      cftime
      pooch
    ];

    parallel = [ dask ] ++ dask.optional-dependencies.complete;

    viz = [
      cartopy
      matplotlib
      # nc-time-axis
      seaborn
    ];
  };

  pyproject = true;

  pytestFlags = lib.optionals (!h5py.hdf5.szipSupport) [
    "-k"
    # Our h5py is built with hdf5 that is built without szip support, so we
    # skip these tests
    "not szip"
  ];

  pythonImportsCheck = [ "xarray" ];

  meta = {
    description = "N-D labeled arrays and datasets in Python";
    homepage = "https://github.com/pydata/xarray";
    changelog = "https://github.com/pydata/xarray/blob/${finalAttrs.src.tag}/doc/whats-new.rst";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      doronbehar
    ];
  };
})
