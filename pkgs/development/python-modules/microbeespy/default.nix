{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  paho-mqtt,
  setuptools,
}:

buildPythonPackage rec {
  pname = "microbeespy";
  version = "0.3.5";

  src = fetchFromGitHub {
    owner = "microBeesTech";
    repo = "pythonSDK";
    tag = version;
    hash = "sha256-h3IbWdZ/iHsNlAr/DfASj4dKNkQ4t1mUUeUIs00L8iU=";
  };

  # Package doesn't include tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    paho-mqtt
  ];

  pyproject = true;
  pythonImportsCheck = [ "microBeesPy" ];

  meta = {
    description = "Official microBees Python Library";
    homepage = "https://github.com/microBeesTech/pythonSDK";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
