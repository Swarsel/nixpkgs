{
  lib,
  aiohttp,
  # dependencies
  aiomqtt,
  buildPythonPackage,
  certifi,
  fetchPypi,
  # build-system
  poetry-core,
}:

buildPythonPackage rec {
  pname = "miraie-ac";
  version = "1.1.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-IiRDPz5IcD3Df+vw4YvR3zc0oThGjb7pBJfD4d98h/g=";
    pname = "miraie_ac";
  };

  build-system = [ poetry-core ];

  dependencies = [
    aiomqtt
    aiohttp
    certifi
  ];

  pyproject = true;
  pythonImportsCheck = [ "miraie_ac" ];
  pythonRemoveDeps = [ "asyncio" ];

  meta = {
    description = "Python library for controlling Panasonic Miraie ACs";
    homepage = "https://github.com/rkzofficial/miraie-ac";
    changelog = "https://github.com/rkzofficial/miraie-ac/releases";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ananthb ];
  };
}
