{
  lib,
  fetchFromGitHub,
  affine,
  async-tiff,
  buildPythonPackage,
  defusedxml,
  jsonschema,
  morecantile,
  numpy,
  # tests
  pydantic,
  pyproj,
  pytest-asyncio,
  pytestCheckHook,
  rasterio,
  uv-build,
}:
buildPythonPackage (finalAttrs: {
  pname = "async-geotiff";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "async-geotiff";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VC4I1ZDKC2Joh2lxscZ1UWp5p5wOEPKjTq+Ty2Z0PJc=";
    fetchSubmodules = true;
  };

  nativeCheckInputs = [ pytestCheckHook ];

  checkInputs = [
    jsonschema
    morecantile
    rasterio
    pydantic
    pytest-asyncio
  ];

  build-system = [ uv-build ];

  dependencies = [
    affine
    async-tiff
    defusedxml
    numpy
    pyproj
  ];

  pyproject = true;
  pythonImportsCheck = [ "async_geotiff" ];

  meta = {
    description = "Fast, async GeoTIFF and COG reader for Python";
    homepage = "https://developmentseed.org/async-geotiff/latest/";
    license = lib.licenses.mit;
    teams = [ lib.teams.geospatial ];
  };
})
