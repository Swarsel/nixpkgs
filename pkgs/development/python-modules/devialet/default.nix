{
  lib,
  fetchFromGitHub,
  aiohttp,
  async-upnp-client,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "devialet";
  version = "1.5.7";

  src = fetchFromGitHub {
    owner = "fwestenberg";
    repo = "devialet";
    tag = "v${version}";
    hash = "sha256-HmTiHa7DEmjARaYn7/OoGotnTirE7S7zXLK/TfHdEAg=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    async-upnp-client
  ];

  pyproject = true;
  pythonImportsCheck = [ "devialet" ];

  meta = {
    description = "Library to interact with the Devialet API";
    homepage = "https://github.com/fwestenberg/devialet";
    changelog = "https://github.com/fwestenberg/devialet/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
