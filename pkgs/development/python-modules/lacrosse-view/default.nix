{
  lib,
  fetchFromGitHub,
  aiohttp,
  aiozoneinfo,
  buildPythonPackage,
  pydantic,
  setuptools,
}:

buildPythonPackage rec {
  pname = "lacrosse-view";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "IceBotYT";
    repo = "lacrosse_view";
    tag = "v${version}";
    hash = "sha256-KU3/w/LpbDNmrE70wj7j1ztKn+k4wP6RzvUU1p50i2A=";
  };

  # No tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    aiozoneinfo
    pydantic
  ];

  pyproject = true;
  pythonImportsCheck = [ "lacrosse_view" ];

  meta = {
    description = "Client for retrieving data from the La Crosse View cloud";
    homepage = "https://github.com/IceBotYT/lacrosse_view";
    changelog = "https://github.com/IceBotYT/lacrosse_view/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
