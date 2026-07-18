{
  lib,
  fetchFromGitHub,
  async-geotiff,
  attrs,
  boto3,
  buildPythonPackage,
  cachetools,
  color-operations,
  h5netcdf,
  hatchling,
  httpx2,
  morecantile,
  numexpr,
  numpy,
  obstore,
  pydantic,
  pystac,
  pytest-asyncio,
  pytestCheckHook,
  rasterio,
  rioxarray,
  typing-extensions,
  zarr,
}:

buildPythonPackage (finalAttrs: {
  pname = "rio-tiler";
  version = "9.3.0";

  src = fetchFromGitHub {
    owner = "cogeotiff";
    repo = "rio-tiler";
    tag = finalAttrs.version;
    hash = "sha256-Tf3F/XRGdPDZqlXQfRc5cvGvUvu94Y6TO2cFqjFsg5g=";
  };

  nativeCheckInputs = [
    h5netcdf
    pytestCheckHook
    pytest-asyncio
  ]
  ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);

  build-system = [ hatchling ];

  dependencies = [
    attrs
    cachetools
    color-operations
    httpx2
    morecantile
    numexpr
    numpy
    pydantic
    pystac
    rasterio
    typing-extensions
  ];

  disabledTests = [
    # Requires network access
    "test_dataset_reader"
    # for some reason, str date representation are not the same
    "test_xarray_reader"
    "test_geoxarray_reader_coordinates"
    "test_geoxarray_reader_compat"
  ];

  optional-dependencies = {
    geotiff = [
      async-geotiff
      obstore
    ];

    s3 = [ boto3 ];
    xarray = [ rioxarray ];

    zarr = [
      obstore
      zarr
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "rio_tiler" ];

  meta = {
    description = "User friendly Rasterio plugin to read raster datasets";
    homepage = "https://cogeotiff.github.io/rio-tiler/";
    license = lib.licenses.bsd3;
    teams = [ lib.teams.geospatial ];
  };
})
