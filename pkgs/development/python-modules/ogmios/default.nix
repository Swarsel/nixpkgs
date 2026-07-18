{
  lib,
  buildPythonPackage,
  # Python deps
  cachetools,
  cardano-tools,
  coloredlogs,
  fetchPypi,
  hatchling,
  orjson,
  pydantic,
  setuptools,
  websockets,
}:

buildPythonPackage rec {
  pname = "ogmios";
  version = "1.4.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-+edW34O+OF+JyCoZSjxRwKS6JeXfaZ38+ykUpXwBJ1Q=";
    pname = "ogmios";
  };

  build-system = [
    hatchling
    setuptools
  ];

  dependencies = [
    cachetools
    cardano-tools
    coloredlogs
    orjson
    pydantic
    websockets
  ];

  pyproject = true;
  pythonImportsCheck = [ "ogmios" ];

  meta = {
    description = "Python client for Ogmios";
    homepage = "https://gitlab.com/viperscience/ogmios-python";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ aciceri ];
  };
}
