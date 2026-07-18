{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "area";
  version = "1.1.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-yuu5Zmjd7dtQ5/Vu0jbaO4RFn262fwMGplLBTiuHZaI=";
  };

  # tests not working on the package from pypi
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "area" ];

  meta = {
    description = "Calculate the area inside of any GeoJSON geometry. This is a port of Mapbox’s geojson-area for Python";
    homepage = "https://github.com/scisco/area";
    license = lib.licenses.bsd2;
  };
})
