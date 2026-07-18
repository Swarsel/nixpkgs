{
  lib,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
  requests,
}:

buildPythonPackage rec {
  pname = "hydrus-api";
  version = "5.1.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-oA3DbdX+MRZiInCKXurBdKlUFQ4jeU+jHr9NxMEHQmI=";
    pname = "hydrus_api";
  };

  # There are no unit tests
  doCheck = false;
  build-system = [ poetry-core ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "hydrus_api" ];

  meta = {
    description = "Python module implementing the Hydrus API";
    homepage = "https://gitlab.com/cryzed/hydrus-api";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ dandellion ];
  };
}
