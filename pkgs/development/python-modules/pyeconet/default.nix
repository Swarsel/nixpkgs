{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  paho-mqtt,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyeconet";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "w1ll1am23";
    repo = "pyeconet";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sQXIMm5ddkqkFgTYOsy9srKxLUy505iFhrtGAbOLzc0=";
  };

  # Tests require credentials
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    paho-mqtt
    aiohttp
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyeconet" ];
  pythonRelaxDeps = [ "paho-mqtt" ];

  meta = {
    description = "Python interface to the EcoNet API";
    homepage = "https://github.com/w1ll1am23/pyeconet";
    changelog = "https://github.com/w1ll1am23/pyeconet/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
