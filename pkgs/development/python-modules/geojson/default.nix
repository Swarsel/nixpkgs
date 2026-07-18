{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "geojson";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "jazzband";
    repo = "geojson";
    tag = finalAttrs.version;
    hash = "sha256-Gz+hiv0CxitE+upLsiln+H8TtWezpUDaPH80UM7VHTA=";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "geojson" ];

  meta = {
    description = "Python bindings and utilities for GeoJSON";
    homepage = "https://github.com/jazzband/geojson";
    changelog = "https://github.com/jazzband/geojson/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    teams = [ lib.teams.geospatial ];
  };
})
