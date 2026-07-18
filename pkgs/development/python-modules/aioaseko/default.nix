{
  lib,
  fetchFromGitHub,
  aiohttp,
  apischema,
  buildPythonPackage,
  gql,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aioaseko";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "milanmeu";
    repo = "aioaseko";
    tag = "v${version}";
    hash = "sha256-jUvpu/lOFKRUwEuYD1zRp0oODjf4AgH84fnGngtv9jw=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    apischema
    gql
  ];

  pyproject = true;
  pythonImportsCheck = [ "aioaseko" ];

  meta = {
    description = "Module to interact with the Aseko Pool Live API";
    homepage = "https://github.com/milanmeu/aioaseko";
    changelog = "https://github.com/milanmeu/aioaseko/releases/tag/v${version}";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ fab ];
  };
}
