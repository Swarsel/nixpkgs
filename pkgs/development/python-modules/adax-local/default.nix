{
  lib,
  fetchFromGitHub,
  aiohttp,
  async-timeout,
  bleak,
  bleak-retry-connector,
  buildPythonPackage,
  setuptools_80,
}:

buildPythonPackage rec {
  pname = "adax-local";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "Danielhiversen";
    repo = "pyAdaxLocal";
    tag = version;
    hash = "sha256-8gVpUYQoE4V3ATR6zFAz/sARyEmHu9lYyGchTpS1eX8=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools_80 ];

  dependencies = [
    aiohttp
    bleak
    bleak-retry-connector
    async-timeout
  ];

  pyproject = true;
  pythonImportsCheck = [ "adax_local" ];

  meta = {
    description = "Module for local access to Adax";
    homepage = "https://github.com/Danielhiversen/pyAdaxLocal";
    changelog = "https://github.com/Danielhiversen/pyAdaxLocal/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
