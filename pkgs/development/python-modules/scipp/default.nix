{
  lib,
  stdenv,
  fetchFromGitHub,
  beautifulsoup4,
  # buildInputs
  boost,
  buildPythonPackage,
  # nativeBuildInputs
  cmake,
  eigen,
  gtest,
  h5py,
  hypothesis,
  ipython,
  matplotlib,
  ninja,
  numba,
  # dependencies
  numpy,
  onetbb,
  pandas,
  pybind11,
  # tests
  pytestCheckHook,
  # build-system
  scikit-build-core,
  scipy,
  setuptools,
  setuptools-scm,
  units-llnl,
  xarray,
}:

buildPythonPackage rec {
  pname = "scipp";
  version = "26.3.1";

  src = fetchFromGitHub {
    owner = "scipp";
    repo = "Scipp";
    tag = version;
    hash = "sha256-Jbp7dOEAnXe9kBcYt35iC01i6FnZkFY5n9okGCeuuL4=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    boost
    eigen
    gtest
    pybind11
    units-llnl.passthru.top-level
    onetbb
  ];

  env = {
    SKIP_REMOTE_SOURCES = "true";
  };

  nativeCheckInputs = [
    pytestCheckHook
    scipy
    beautifulsoup4
    ipython
    matplotlib
    pandas
    numba
    xarray
    h5py
    hypothesis
  ];

  build-system = [
    scikit-build-core
    setuptools
    setuptools-scm
  ];

  dependencies = [
    numpy
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;

  pytestFlags = [
    # See https://github.com/scipp/scipp/issues/3721
    "--hypothesis-profile=ci"
  ];

  pythonImportsCheck = [
    "scipp"
  ];

  meta = {
    description = "Multi-dimensional data arrays with labeled dimensions";
    homepage = "https://scipp.github.io";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
