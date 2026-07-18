{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  python-socks,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aiohttp-socks";
  version = "0.11.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Cv5RY4Unx5B35L1uVwUsh8SCQjPW4guwYcU3ZkIbEPA=";
    pname = "aiohttp_socks";
  };

  # Checks needs internet access
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    python-socks
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiohttp_socks" ];

  meta = {
    description = "SOCKS proxy connector for aiohttp";
    homepage = "https://github.com/romis2012/aiohttp-socks";
    changelog = "https://github.com/romis2012/aiohttp-socks/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
