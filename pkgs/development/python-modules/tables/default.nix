{
  lib,
  stdenv,
  fetchFromGitHub,
  # build-inputs
  blosc2,
  buildPythonPackage,
  bzip2,
  c-blosc,
  # build-system
  cython,
  hdf5,
  lzo,
  # dependencies
  numexpr,
  numpy,
  packaging, # uses packaging.version at runtime
  pkg-config,
  py-cpuinfo,
  # Test inputs
  python,
  setuptools,
  sphinx,
  typing-extensions,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "tables";
  version = "3.11.1";

  src = fetchFromGitHub {
    owner = "PyTables";
    repo = "PyTables";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ImzfUc+B5odozROkwhnDUY2a9XDXn8Il2wKuLzOvKAg=";
    fetchSubmodules = true;
  };

  postPatch = ''
    # Force test suite to error when unittest runner fails
    substituteInPlace tables/tests/test_suite.py \
      --replace-fail "return 0" "assert result.wasSuccessful(); return 0" \
      --replace-fail "return 1" "assert result.wasSuccessful(); return 1"
    # Hard-code the blosc2 path to avoid issues with blosc2.c-blosc2
    substituteInPlace tables/__init__.py \
      --replace-fail "ctypes.CDLL(str(lib_path))" \
      "ctypes.CDLL('"${lib.getLib c-blosc}/lib/libblosc${stdenv.hostPlatform.extensions.sharedLibrary}"')"
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    blosc2
    bzip2
    c-blosc
    blosc2.c-blosc2
    hdf5
    lzo
  ];

  env = {
    BLOSC2_DIR = lib.getDev blosc2.c-blosc2;
    BLOSC_DIR = lib.getDev c-blosc;
    BZIP2_DIR = lib.getDev bzip2;
    HDF5_DIR = lib.getDev hdf5;
    LZO_DIR = lib.getDev lzo;
  };

  nativeCheckInputs = [
    python
    writableTmpDirAsHomeHook
  ];

  preCheck = ''
    cd tables/tests
  '';

  # Runs the light (yet comprehensive) subset of the test suite.
  # Pass `--heavy` for the whole "heavy" test suite (hour+ runtime).
  checkPhase = ''
    runHook preCheck
    ${python.interpreter} -m tables.tests.test_all
    runHook postCheck
  '';

  __structuredAttrs = true;

  build-system = [
    cython
    setuptools
    sphinx
  ];

  dependencies = [
    blosc2
    c-blosc
    blosc2.c-blosc2
    py-cpuinfo
    numpy
    numexpr
    packaging # uses packaging.version at runtime
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "tables" ];

  meta = {
    description = "Hierarchical datasets for Python";
    homepage = "https://www.pytables.org/";
    changelog = "https://github.com/PyTables/PyTables/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ sarahec ];
  };
})
