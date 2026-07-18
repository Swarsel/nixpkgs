{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aioqsw";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "Noltari";
    repo = "aioqsw";
    tag = version;
    hash = "sha256-2v3PhhlVeQs/jMnOzji/aKeWD7pWfqXVf4iBOgXD7kc=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "aioqsw" ];

  meta = {
    description = "Library to fetch data from QNAP QSW switches";
    homepage = "https://github.com/Noltari/aioqsw";
    changelog = "https://github.com/Noltari/aioqsw/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
