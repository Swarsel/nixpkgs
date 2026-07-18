{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  cramjam,
  # build-system
  cython,
  fsspec,
  # nativeBuildInputs
  gitMinimal,
  numpy,
  packaging,
  pandas,
  # tests
  pytestCheckHook,
  python,
  # optional-dependencies
  python-lzo,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "fastparquet";
  version = "2026.5.0";

  src = fetchFromGitHub {
    owner = "dask";
    repo = "fastparquet";
    tag = version;
    hash = "sha256-thvoMXXiGtHGcJ0/IrGujjhVAvSmTMGmrlDHjG8R7PQ=";
  };

  nativeBuildInputs = [
    gitMinimal
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  # Workaround https://github.com/NixOS/nixpkgs/issues/123561
  preCheck = ''
    mv fastparquet/test .
    rm -r fastparquet
    fastparquet_test="$out"/${python.sitePackages}/fastparquet/test
    ln -s `pwd`/test "$fastparquet_test"
  '';

  postCheck = ''
    rm "$fastparquet_test"
  '';

  build-system = [
    cython
    setuptools
    setuptools-scm
  ];

  dependencies = [
    cramjam
    fsspec
    numpy
    packaging
    pandas
  ];

  disabledTests = [
    # DeprecationWarning: The 'generic' unit for NumPy timedelta is deprecated,
    # and will raise an error in the future. This includes implicit conversion of bare
    # integers (e.g. `+ 1`).Please use a specific unit instead.
    "test_import_without_warning"
  ];

  optional-dependencies = {
    lzo = [ python-lzo ];
  };

  pyproject = true;
  pythonImportsCheck = [ "fastparquet" ];

  meta = {
    description = "Implementation of the parquet format";
    homepage = "https://github.com/dask/fastparquet";
    changelog = "https://github.com/dask/fastparquet/blob/${version}/docs/source/releasenotes.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ veprbl ];
  };
}
