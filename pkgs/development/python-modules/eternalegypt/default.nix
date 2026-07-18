{
  lib,
  fetchFromGitHub,
  aiohttp,
  attrs,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "eternalegypt";
  version = "0.0.18";

  src = fetchFromGitHub {
    owner = "amelchio";
    repo = "eternalegypt";
    tag = "v${version}";
    hash = "sha256-dS4APZWOI8im1Ls1A5750FedTWBy3UpXvJmYpd1po94=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    attrs
  ];

  pyproject = true;
  pythonImportsCheck = [ "eternalegypt" ];

  meta = {
    description = "Python API for Netgear LTE modems";
    homepage = "https://github.com/amelchio/eternalegypt";
    changelog = "https://github.com/amelchio/eternalegypt/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
