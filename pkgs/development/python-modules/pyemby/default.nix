{
  lib,
  fetchFromGitHub,
  aiohttp,
  async-timeout,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyemby";
  version = "1.10";

  src = fetchFromGitHub {
    owner = "mezz64";
    repo = "pyemby";
    tag = version;
    hash = "sha256-+A/SNMCUqo9TwWsQXwOKJCqmYhbilIdHYazLNQY+NkU=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    async-timeout
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyemby" ];

  meta = {
    description = "Python library to interface with the Emby API";
    homepage = "https://github.com/mezz64/pyemby";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
