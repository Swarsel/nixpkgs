{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  duckdb,
  fsspec,
  google-cloud-storage,
  ipython,
  ninja,
  numpy,
  openssl,
  pandas,
  psutil,
  pyarrow,
  pybind11,
  pytest-reraise,
  pytestCheckHook,
  pytz,
  scikit-build-core,
  setuptools-scm,
  typing-extensions,
}:

buildPythonPackage rec {
  inherit (duckdb)
    pname
    version # nixpkgs-update: no auto update
    ;

  src = fetchFromGitHub {
    owner = "duckdb";
    repo = "duckdb-python";
    tag = "v${version}";
    hash = duckdb.passthru.pythonHash;
  };

  postPatch = ''
    # The build depends on a duckdb git submodule
    rm -r external/duckdb
    ln -s ${duckdb.src} external/duckdb

    # replace pybind11[global] with pybind11
    substituteInPlace pyproject.toml \
      --replace-fail "pybind11[global]" "pybind11"

    # replace custom build backend with standard scikit-build-core
    substituteInPlace pyproject.toml \
      --replace-fail 'build-backend = "duckdb_packaging.build_backend"' \
                     'build-backend = "scikit_build_core.build"' \
      --replace-fail 'backend-path = ["./"]' \
                     '# backend-path removed'
  '';

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    duckdb
    openssl
  ];

  cmakeFlags = [
    (lib.cmakeFeature "OVERRIDE_GIT_DESCRIBE" "v${version}-0-g${duckdb.rev}")
  ];

  env = {
    CMAKE_DEFINE_DUCKDB_EXTENSION_AUTOINSTALL_DEFAULT = "0";
    # default to disabled extension autoload/autoinstall
    CMAKE_DEFINE_DUCKDB_EXTENSION_AUTOLOAD_DEFAULT = "0";
    DUCKDB_BUILD_UNITY = 1;
  };

  nativeCheckInputs = [
    fsspec
    google-cloud-storage
    psutil
    pytest-reraise
    pytestCheckHook
    pytz
  ]
  ++ optional-dependencies.all;

  # remove duckdb dir to prevent import confusion by pytest
  preCheck = ''
    export HOME="$(mktemp -d)"
    rm -rf duckdb
  '';

  build-system = [
    pybind11
    scikit-build-core
    setuptools-scm
  ];

  dependencies = [
    typing-extensions
  ];

  disabledTestPaths = [
    # avoid dependency on adbc_driver_manager
    "tests/fast/adbc"
    # avoid dependency on pyotp
    "tests/fast/test_pypi_cleanup.py"
    # avoid test data download requiring network access
    "tests/slow/test_h2oai_arrow.py"
  ];

  disabledTests = [
    # tries to make http request
    "test_install_non_existent_extension"

    # test is flaky https://github.com/duckdb/duckdb/issues/11961
    "test_fetchmany"

    # https://github.com/duckdb/duckdb/issues/10702
    # tests are racy and interrupt can be delivered before or after target point
    # causing a later test to fail with a spurious KeyboardInterrupt
    "test_connection_interrupt"
    "test_query_interruption"

    # flaky due to a race condition in checking whether a thread is alive
    "test_query_progress"
  ];

  dontUseCmakeConfigure = true;
  enabledTestPaths = if stdenv.hostPlatform.isDarwin then [ "tests/fast" ] else [ "tests" ];

  optional-dependencies = {
    all = [
      # FIXME package adbc_driver_manager
      ipython
      fsspec
      numpy
      pandas
      pyarrow
    ];
  };

  pyproject = true;

  # test flags from .github/workflows/Python.yml
  pytestFlags = [
    "--verbose"
    "-Wignore::DeprecationWarning"
  ];

  pythonImportsCheck = [ "duckdb" ];

  meta = {
    description = "Python binding for DuckDB";
    homepage = "https://duckdb.org/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      cameronraysmith
      cpcloud
    ];
  };
}
