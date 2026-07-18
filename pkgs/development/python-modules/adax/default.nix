{
  lib,
  fetchFromGitHub,
  aiohttp,
  async-timeout,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "adax";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "Danielhiversen";
    repo = "pyadax";
    tag = finalAttrs.version;
    hash = "sha256-wmcZtiML02i1XfqpFzni2WDrxutTvP5laVvTAGtNg0Y=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    async-timeout
  ];

  pyproject = true;
  pythonImportsCheck = [ "adax" ];

  meta = {
    description = "Python module to communicate with Adax";
    homepage = "https://github.com/Danielhiversen/pyAdax";
    changelog = "https://github.com/Danielhiversen/pyAdax/releases/tag/${finalAttrs.version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
})
