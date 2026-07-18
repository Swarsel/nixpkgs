{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dask,
  dask-image,
  fsspec,
  hatch-vcs,
  hatchling,
  ngff-zarr,
  numpy,
  python-dateutil,
  spatial-image,
  writableTmpDirAsHomeHook,
  xarray,
  xarray-dataclass,
  zarr,
}:

buildPythonPackage (finalAttrs: {
  pname = "multiscale-spatial-image";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "spatial-image";
    repo = "multiscale-spatial-image";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uF9ZccLvP1ref6qn3l6EpedsoK29Q8lAdr68JjsYMis=";
  };

  nativeBuildInputs = [ writableTmpDirAsHomeHook ];
  doCheck = false; # all test files try to download data

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    dask
    ngff-zarr
    numpy
    python-dateutil
    spatial-image
    xarray
    xarray-dataclass
    zarr
  ];

  optional-dependencies = {
    dask-image = [ dask-image ];
    #itk = [
    #  itk-filtering # not in nixpkgs yet
    #];
  };

  pyproject = true;
  pythonImportsCheck = [ "multiscale_spatial_image" ];

  pythonRelaxDeps = [
    "dask"
    "ngff-zarr"
    "xarray"
  ];

  meta = {
    description = "Generate a multiscale, chunked, multi-dimensional spatial image data structure that can serialized to OME-NGFF";
    homepage = "https://github.com/spatial-image/multiscale-spatial-image";
    changelog = "https://github.com/spatial-image/multiscale-spatial-image/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
})
