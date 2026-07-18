{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
  websockets,
}:

buildPythonPackage rec {
  pname = "pyhomee";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "Taraman17";
    repo = "pyHomee";
    tag = "v${version}";
    hash = "sha256-9oXMDvYN43qNbzNlbkEjBekmmRyHIOKgYUXpI2W3jdo=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    websockets
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyHomee" ];

  meta = {
    description = "Python library to interact with homee";
    homepage = "https://github.com/Taraman17/pyHomee";
    changelog = "https://github.com/Taraman17/pyHomee/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
