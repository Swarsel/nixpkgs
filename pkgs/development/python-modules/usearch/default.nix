{
  lib,
  stdenv,
  buildPythonPackage,
  cmake,
  numba,
  numkong,
  numpy,
  pkgs,
  py-cpuinfo,
  pybind11,
  pytestCheckHook,
  setuptools,
  tqdm,
  which,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage {
  inherit (pkgs.usearch) pname version src;

  postPatch = ''
    substituteInPlace python/usearch/__init__.py \
      --replace-fail 'manager = BinaryManager(version=version)' \
        'return "${lib.getLib pkgs.usearch}/lib/libusearch_sqlite${
          if stdenv.hostPlatform.isDarwin then "" else stdenv.hostPlatform.extensions.sharedLibrary
        }"'
  '';

  nativeBuildInputs = [
    which
  ];

  buildInputs = [
    pkgs.numkong
  ];

  nativeCheckInputs = [
    numba
    py-cpuinfo
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  __structuredAttrs = true;

  build-system = [
    cmake
    pybind11
    setuptools
  ];

  dependencies = [
    numkong
    numpy
    tqdm
  ];

  disabledTests = lib.optionals (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64) [
    # Numerical precision error (AssertionError)
    "test_index_clustering"
    "test_index_retrieval"
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "usearch" ];

  meta = {
    inherit (pkgs.usearch.meta)
      description
      homepage
      changelog
      license
      maintainers
      ;
  };
}
