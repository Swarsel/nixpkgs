{
  lib,
  buildPythonPackage,
  ciso8601,
  fetchPypi,
  hatchling,
  requests,
}:

buildPythonPackage rec {
  pname = "dwdwfsapi";
  version = "1.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-7dIVD+4MiYtsjAM5j67MlbiUN2Q5DpK6bUU0ZuHN2rk=";
  };

  # All tests require network access
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    requests
    ciso8601
  ];

  pyproject = true;
  pythonImportsCheck = [ "dwdwfsapi" ];

  meta = {
    description = "Python client to retrieve data provided by DWD via their geoserver WFS API";
    homepage = "https://github.com/stephan192/dwdwfsapi";
    changelog = "https://github.com/stephan192/dwdwfsapi/blob/v${version}/CHANGELOG.md";
    license = with lib.licenses; [ mit ];
  };
}
