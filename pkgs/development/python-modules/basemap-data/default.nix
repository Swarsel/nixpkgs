{
  lib,
  basemap,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  inherit (basemap) version src;
  pname = "basemap-data";
  # no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "mpl_toolkits.basemap_data" ];
  sourceRoot = "${finalAttrs.src.name}/data/basemap_data";

  meta = {
    description = "Data assets for matplotlib basemap";
    homepage = "https://matplotlib.org/basemap/";

    license = with lib.licenses; [
      mit
      lgpl3Plus
    ];

    teams = [ lib.teams.geospatial ];
  };
})
