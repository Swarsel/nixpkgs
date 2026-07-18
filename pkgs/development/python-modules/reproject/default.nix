{
  lib,
  fetchFromGitHub,
  asdf,
  astropy,
  astropy-healpix,
  buildPythonPackage,
  cython,
  dask,
  dask-image,
  extension-helpers,
  fsspec,
  gwcs,
  numpy,
  pillow,
  pyavm,
  pytest-astropy,
  pytest-xdist,
  pytestCheckHook,
  scipy,
  setuptools,
  setuptools-scm,
  shapely,
  tqdm,
  zarr,
}:

buildPythonPackage rec {
  pname = "reproject";
  version = "0.21.0";

  src = fetchFromGitHub {
    owner = "astropy";
    repo = "reproject";
    tag = "v${version}";
    hash = "sha256-IuGVipAb4x63U2k9tNHhps5Gbk+3Hi/1ZkeMTZ/vaiU=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-astropy
    pytest-xdist
    asdf
    gwcs
    shapely
    tqdm
  ];

  build-system = [
    setuptools
    setuptools-scm
    cython
    extension-helpers
    numpy
  ];

  dependencies = [
    astropy
    astropy-healpix
    dask
    dask-image
    fsspec
    numpy
    pillow
    pyavm
    scipy
    zarr
  ]
  ++ dask.optional-dependencies.array;

  disabledTestPaths = [
    # Uses network
    "build/lib*/reproject/interpolation/"
  ];

  enabledTestPaths = [
    "build/lib*"
  ];

  pyproject = true;
  pythonImportsCheck = [ "reproject" ];

  meta = {
    description = "Reproject astronomical images";
    homepage = "https://reproject.readthedocs.io";
    changelog = "https://github.com/astropy/reproject/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ smaret ];
    downloadPage = "https://github.com/astropy/reproject";
  };
}
