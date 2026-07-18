{
  lib,
  basemap,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  inherit (basemap) version src;
  pname = "basemap-data-hires";
  # no tests
  doCheck = false;

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "mpl_toolkits.basemap_data" ];
  sourceRoot = "${src.name}/data/basemap_data_hires";

  meta = {
    description = "High-resolution data assets for matplotlib basemap";
    homepage = "https://matplotlib.org/basemap/";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ moraxyc ];
    teams = with lib.teams; [ geospatial ];
  };
}
