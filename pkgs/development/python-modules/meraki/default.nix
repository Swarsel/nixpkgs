{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
  requests,
}:

buildPythonPackage rec {
  pname = "meraki";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "meraki";
    repo = "dashboard-api-python";
    tag = version;
    hash = "sha256-XP0wvq9CoUpjGsIKmzgLrAmxhJ0F2mHDXJZdeU+AEkE=";
  };

  # All tests require an API key
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "meraki" ];
  pythonRelaxDeps = [ "aiohttp" ];

  meta = {
    description = "Cisco Meraki cloud-managed platform dashboard API python library";
    homepage = "https://github.com/meraki/dashboard-api-python";
    changelog = "https://github.com/meraki/dashboard-api-python/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dylanmtaylor ];
  };
}
