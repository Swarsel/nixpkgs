{
  lib,
  stdenv,
  fetchFromGitHub,
  blas,
  # buildInputs
  boost,
  buildPythonPackage,
  # build-system
  cmake,
  # dependencies
  dask,
  eigen,
  gtest,
  numpy,
  pybind11,
  # tests
  pytestCheckHook,
  setuptools,
  xarray,
}:
buildPythonPackage rec {
  pname = "pyinterp";
  version = "2025.8.1";

  src = fetchFromGitHub {
    owner = "CNES";
    repo = "pangeo-pyinterp";
    tag = version;
    hash = "sha256-9DZIPiqt0JbadeGIkVrg+XuPu4XfVlHm36sBKZ2G7ww=";
  };

  # Remove the git submodule link to pybind11, patch setup.py build backend and version information
  postPatch = ''
    rm -rf third_party/pybind11
    mkdir -p third_party
    ln -sr ${pybind11.src} third_party/pybind11

    substituteInPlace pyproject.toml --replace-fail 'build-backend = "backend"' 'build-backend = "setuptools.build_meta"'
    substituteInPlace pyproject.toml --replace-fail 'backend-path = ["_custom_build"]' ""

    substituteInPlace setup.py \
      --replace-fail 'version=revision(),' 'version="${version}",'

    substituteInPlace src/pyinterp/__init__.py \
     --replace-fail 'from . import geodetic, geohash, version' 'from . import geodetic, geohash' \
     --replace-fail '__version__ = version.release()' '__version__ = "${version}"' \
     --replace-fail '__date__ = version.date()' '__date__ = "${version}"' \
     --replace-fail 'del version' ""
  '';

  buildInputs = [
    blas
    boost
    eigen
    gtest
    pybind11
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    cmake
    setuptools
  ];

  dependencies = [
    dask
    numpy
    xarray
  ];

  disabledTests = [
    # segmentation fault
    "test_bounding_box"
    "test_geohash"
    "test_encoding"
    "test_neighbors"
  ]
  ++ lib.optionals stdenv.hostPlatform.isAarch64 [
    # AssertionError, probably floating point precision differences
    "test_quadrivariate"
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;

  pythonImportsCheck = [
    "pyinterp"
    "pyinterp.geohash"
  ];

  meta = {
    description = "Python library for optimized geo-referenced interpolation";
    homepage = "https://github.com/CNES/pangeo-pyinterp";
    changelog = "https://github.com/CNES/pangeo-pyinterp/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ daspk04 ];
  };
}
