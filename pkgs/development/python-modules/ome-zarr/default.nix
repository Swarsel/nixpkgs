{
  lib,
  fetchFromGitHub,
  # dependencies
  aiohttp,
  buildPythonPackage,
  dask,
  deprecated,
  fsspec,
  numpy,
  # tests
  ome-zarr-models,
  pytestCheckHook,
  rangehttpserver,
  requests,
  scikit-image,
  # build-system
  setuptools,
  setuptools-scm,
  toolz,
  zarr,
}:

buildPythonPackage (finalAttrs: {
  pname = "ome-zarr";
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "ome";
    repo = "ome-zarr-py";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cuvPlPvhCoivMPpesARnc0+fUqwxjeHyZ2E1e1iHUb8=";
  };

  nativeCheckInputs = [
    ome-zarr-models
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    aiohttp
    dask
    deprecated
    fsspec
    numpy
    rangehttpserver
    requests
    scikit-image
    toolz
    zarr
  ]
  ++ fsspec.optional-dependencies.s3;

  disabledTestPaths = [
    # tries to access network:
    "ome_zarr/io.py"
  ];

  disabledTests = [
    # attempts to access network
    "test_class_reader"
    "test_class_reader_legacy"
    "test_s3_info"

    # AssertionError: assert {'blocksize':... 'blosc', ...} == {'blocksize':... 'blosc', ...}
    # comp {'id': 'blosc', 'cname': 'lz4', 'clevel': 5, 'shuffle': 1, 'blocksize': 0}
    "test_default_compression"
    "test_write_image_compressed"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "ome_zarr"
    "ome_zarr.cli"
    "ome_zarr.csv"
    "ome_zarr.data"
    "ome_zarr.format"
    "ome_zarr.io"
    "ome_zarr.reader"
    "ome_zarr.writer"
    "ome_zarr.scale"
    "ome_zarr.utils"
  ];

  pythonRelaxDeps = [
    "dask"
  ];

  meta = {
    description = "Implementation of next-generation file format (NGFF) specifications for storing bioimaging data in the cloud";
    homepage = "https://pypi.org/project/ome-zarr";
    changelog = "https://github.com/ome/ome-zarr-py/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.bcdarwin ];
    mainProgram = "ome_zarr";
  };
})
