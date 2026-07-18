{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  cython,
  hypothesis,
  isPy3k,
  ninja,
  numpy,
  packaging,
  pandas,
  psutil,
  pyarrow,
  pybind11,
  pytest,
  python,
  scikit-build-core,
  setuptools-scm,
  tiledb,
  wheel,
}:

buildPythonPackage rec {
  pname = "tiledb";
  version = "0.36.1";

  src = fetchFromGitHub {
    owner = "TileDB-Inc";
    repo = "TileDB-Py";
    tag = version;
    hash = "sha256-LzXj6bs+DuOMDhPeXAmBuarA+eEe67LWWnhpNhR660k=";
  };

  buildInputs = [ tiledb ];

  propagatedBuildInputs = [
    numpy
  ];

  env.TILEDB_PATH = tiledb;

  nativeCheckInputs = [
    psutil
    # optional
    pandas
    pytest
    hypothesis
    pyarrow
  ];

  # We have to run pytest from a diffferent directory to force it to import tiledb from $out
  # otherwise it cannot be imported because extension modules are not compiled in sources
  checkPhase = ''
    pushd "$TMPDIR"
    ${python.interpreter} -m pytest --pyargs tiledb${lib.optionalString stdenv.hostPlatform.isDarwin " -k 'not test_ctx_thread_cleanup and not test_array'"}
    popd
  '';

  build-system = [
    cython
    pybind11
    setuptools-scm
    scikit-build-core
    packaging
    cmake
    ninja
  ];

  disabled = !isPy3k; # Not bothering with python2 anymore
  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "tiledb" ];

  meta = {
    description = "Python interface to the TileDB storage manager";
    homepage = "https://github.com/TileDB-Inc/TileDB-Py";
    license = lib.licenses.mit;
  };
}
