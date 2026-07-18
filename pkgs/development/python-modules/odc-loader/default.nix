{
  lib,
  fetchFromGitHub,
  # optional-dependencies
  botocore,
  buildPythonPackage,
  # dependencies
  dask,
  # build-system
  flit,
  # tests
  geopandas,
  numpy,
  odc-geo,
  pytestCheckHook,
  rasterio,
  setuptools,
  xarray,
  zarr,
}:

buildPythonPackage (finalAttrs: {
  pname = "odc-loader";
  version = "0.6.4";

  src = fetchFromGitHub {
    owner = "opendatacube";
    repo = "odc-loader";
    tag = finalAttrs.version;
    hash = "sha256-nJSC93+uPzsZY0ZHmrodPkCIk2FZnZ2ksfJIvr+x0As=";
  };

  nativeCheckInputs = [
    geopandas
    pytestCheckHook
  ]
  ++ finalAttrs.passthru.optional-dependencies.all;

  build-system = [
    flit
  ];

  dependencies = [
    dask
    numpy
    odc-geo
    rasterio
    xarray
  ];

  disabledTests = [
    # Require internet access
    "test_mem_reader"
    "test_memreader_aux"
    "test_memreader_zarr"
  ];

  optional-dependencies = lib.fix (self: {
    all = self.botocore ++ self.zarr;
    botocore = [ botocore ];
    zarr = [ zarr ];
  });

  pyproject = true;

  pythonImportsCheck = [
    "odc.loader"
  ];

  meta = {
    description = "Tools for constructing xarray objects from parsed metadata";
    homepage = "https://github.com/opendatacube/odc-loader/";
    changelog = "https://github.com/opendatacube/odc-loader/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ daspk04 ];
  };
})
