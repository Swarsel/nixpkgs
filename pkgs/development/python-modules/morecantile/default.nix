{
  lib,
  fetchFromGitHub,
  # dependencies
  attrs,
  buildPythonPackage,
  click,
  # build-system
  hatchling,
  # tests
  mercantile,
  pydantic,
  pyproj,
  pytestCheckHook,
  rasterio,
  versionCheckHook,
}:

buildPythonPackage rec {
  pname = "morecantile";
  version = "7.0.3";

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "morecantile";
    tag = version;
    hash = "sha256-Hx4duNbTuRfOmNBLN9J6/6URe57aPc8+3SJA7rbW5zs=";
  };

  nativeCheckInputs = [
    mercantile
    pytestCheckHook
    rasterio
    versionCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    attrs
    click
    pydantic
    pyproj
  ];

  pyproject = true;
  pythonImportsCheck = [ "morecantile" ];

  meta = {
    description = "Construct and use map tile grids in different projection";
    homepage = "https://developmentseed.org/morecantile";
    changelog = "https://github.com/developmentseed/morecantile/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    mainProgram = "morecantile";
    downloadPage = "https://github.com/developmentseed/morecantile";
    teams = [ lib.teams.geospatial ];
  };
}
